import Dispatch
import Foundation

/// A type-erased cancellation wrapper.
///
/// Use `AnyCancellation` when you need to store cancellation tokens with different
/// implementations without exposing their concrete types.
///
/// ## Example
/// ```swift
/// class OperationManager {
///     var cancellables: [String: AnyCancellation] = [:]
///
///     func register(_ id: String, cancellation: AnyCancellation) {
///         cancellables[id] = cancellation
///     }
///
///     func cancel(_ id: String) {
///         cancellables[id]?.cancel()
///         cancellables.removeValue(forKey: id)
///     }
/// }
///
/// // With URLSessionTask
/// let task = URLSession.shared.dataTask(with: request)
/// manager.register("fetch", cancellation: AnyCancellation(task))
///
/// // With Task
/// let asyncTask = Task {
///     await fetchData()
/// }
/// manager.register("asyncFetch", cancellation: AnyCancellation(asyncTask))
/// ```
public struct AnyCancellation: Cancellation {
    @usableFromInline let cancelBox: () -> Void
    @usableFromInline let isCancelledBox: () -> Bool

  /// Creates a type-erased cancellation from a concrete cancellation.
  ///
  /// - Parameter cancellation: The cancellation to wrap.
  @inlinable
  public init<C: Cancellation>(_ cancellation: C) {
    self.cancelBox = cancellation.cancel
    self.isCancelledBox = { cancellation.isCancelled }
  }

  /// Creates a type-erased cancellation from closures.
  ///
  /// - Parameters:
  ///   - cancel: The closure to call when cancelling.
  ///   - isCancelled: The closure that returns the cancellation state.
  @inlinable
  public init(cancel: @escaping () -> Void, isCancelled: @escaping () -> Bool = { false }) {
    self.cancelBox = cancel
    self.isCancelledBox = isCancelled
  }

  /// Performs cancellation.
  @inlinable
  public func cancel() {
    cancelBox()
    }

    /// Returns a Boolean value indicating whether the operation has been cancelled.
    @inlinable public var isCancelled: Bool {
        isCancelledBox()
    }
}

// MARK: - Convenience Extensions

extension AnyCancellation {
  /// Creates an `AnyCancellation` from a `Task`.
  ///
  /// - Parameter task: The task to wrap.
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  @inlinable
  public init(_ task: Task<some Any, some Error>) {
    self.cancelBox = { task.cancel() }
    self.isCancelledBox = { task.isCancelled }
  }

  /// Creates an `AnyCancellation` from a `DispatchWorkItem`.
  ///
  /// - Parameter workItem: The work item to wrap.
  @inlinable
  public init(_ workItem: DispatchWorkItem) {
    self.cancelBox = { workItem.cancel() }
    self.isCancelledBox = { workItem.isCancelled }
  }

  /// Creates an `AnyCancellation` from a `URLSessionTask`.
  ///
  /// - Parameter task: The URL session task to wrap.
  @inlinable
  public init(_ task: URLSessionTask) {
    let state = URLSessionTaskCancellationState()
    self.cancelBox = {
      state.markCancelled()
      task.cancel()
    }
    self.isCancelledBox = {
      state.isCancelled
        || task.state == .canceling
        || ((task.error as? URLError)?.code == .cancelled)
    }
  }
}

@usableFromInline
final class URLSessionTaskCancellationState {
    @usableFromInline let lock = NSLock()
    @usableFromInline var cancelled = false

    @usableFromInline
    init() {}

    @usableFromInline
    func markCancelled() {
        lock.lock()
        cancelled = true
    lock.unlock()
  }

    @usableFromInline var isCancelled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return cancelled
  }
}
