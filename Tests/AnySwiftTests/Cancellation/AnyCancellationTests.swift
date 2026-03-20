import Foundation
import Testing

@testable import AnySwift

@Suite("AnyCancellation Tests")
struct AnyCancellationTests {
  @Test("cancels with closure")
  func cancelsWithClosure() {
    var wasCancelled = false
    let cancellation = AnyCancellation(
      cancel: { wasCancelled = true },
      isCancelled: { wasCancelled }
    )

    #expect(cancellation.isCancelled == false)
    cancellation.cancel()
    #expect(cancellation.isCancelled == true)
  }

  @Test("creates from concrete cancellation")
  func createsFromConcreteCancellation() {
    final class MockCancellation: Cancellation {
      private var cancelled = false

      func cancel() {
        cancelled = true
      }

      var isCancelled: Bool {
        cancelled
      }
    }

    let mock = MockCancellation()
    let cancellation = AnyCancellation(mock)

    #expect(cancellation.isCancelled == false)
    cancellation.cancel()
    #expect(cancellation.isCancelled == true)
  }

  @Test("cancels task")
  func cancelsTask() async {
    let task = Task {
      try? await Task.sleep(nanoseconds: 1_000_000_000)
      return "completed"
    }

    let cancellation = AnyCancellation(task)
    #expect(cancellation.isCancelled == false)

    cancellation.cancel()
    #expect(cancellation.isCancelled == true)

    _ = await task.result
    #expect(task.isCancelled)
  }

  @Test("cancels dispatch work item")
  func cancelsDispatchWorkItem() {
    let workItem = DispatchWorkItem {
      // Work item body
    }

    let cancellation = AnyCancellation(workItem)
    #expect(cancellation.isCancelled == false)

    cancellation.cancel()
    #expect(cancellation.isCancelled == true)
  }

  @Test("stores multiple cancellations")
  func storesMultipleCancellations() {
    var cancelledIds: [String] = []

    let cancellations: [String: AnyCancellation] = [
      "first": AnyCancellation(cancel: { cancelledIds.append("first") }),
      "second": AnyCancellation(cancel: { cancelledIds.append("second") }),
    ]

    cancellations["first"]?.cancel()
    #expect(cancelledIds == ["first"])

    cancellations["second"]?.cancel()
    #expect(cancelledIds == ["first", "second"])
  }

  @Test("url session cancellation remains cancelled after completion")
  func urlSessionCancellationRemainsCancelledAfterCompletion() async {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [DelayedURLProtocol.self]
    let session = URLSession(configuration: configuration)
    let context = URLSessionCancellationContext()
    let url = URL(string: "https://example.com/cancel")!

    defer {
      session.invalidateAndCancel()
    }

    await withCheckedContinuation { continuation in
      let task = session.dataTask(with: url) { _, _, _ in
        continuation.resume()
      }
      let cancellation = AnyCancellation(task)

      context.task = task
      context.cancellation = cancellation

      #expect(cancellation.isCancelled == false)

      task.resume()
      cancellation.cancel()
    }

    #expect(context.task?.state == .completed)
    #expect(context.cancellation?.isCancelled == true)
  }
}

private final class URLSessionCancellationContext {
  var task: URLSessionTask?
  var cancellation: AnyCancellation?
}

private class DelayedURLProtocol: URLProtocol {
  private var workItem: DispatchWorkItem?

  override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    let workItem = DispatchWorkItem { [weak self] in
      guard let self, let client = self.client, let url = self.request.url else { return }

      let response = HTTPURLResponse(
        url: url,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )!
      client.urlProtocol(
        self,
        didReceive: response,
        cacheStoragePolicy: .notAllowed
      )
      client.urlProtocol(self, didLoad: Data())
      client.urlProtocolDidFinishLoading(self)
    }

    self.workItem = workItem
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.05, execute: workItem)
  }

  override func stopLoading() {
    workItem?.cancel()
  }
}
