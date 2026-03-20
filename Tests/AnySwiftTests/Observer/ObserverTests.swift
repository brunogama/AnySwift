import Testing

@testable import AnySwift

@Suite("Observer Tests")
struct ObserverTests {
  @Test("passthrough subject unsubscribes copied observer value")
  func passthroughSubjectUnsubscribesCopiedObserverValue() {
    let subject = PassthroughSubject<Int>()
    var received: [Int] = []

    let observer = AnyObserver<Int>(onNext: { received.append($0) })
    let copiedObserver = observer

    subject.subscribe(observer)
    subject.send(1)
    subject.unsubscribe(copiedObserver)
    subject.send(2)

    #expect(received == [1])
  }
}
