/// A type that defines cancellation behavior.
///
/// The `Cancellation` protocol is useful for abstracting different cancellation
/// mechanisms such as `Task.cancel()`, `DispatchWorkItem.cancel()`, or custom
/// cancellation logic.
///
/// ## Example
/// ```swift
/// struct NetworkRequestCancellation: Cancellation {
///     let task: URLSessionDataTask
///
///     func cancel() {
///         task.cancel()
///     }
/// }
/// ```
public protocol Cancellation {
    /// Performs cancellation.
    func cancel()

    /// Returns a Boolean value indicating whether the operation has been cancelled.
    var isCancelled: Bool { get }
}
