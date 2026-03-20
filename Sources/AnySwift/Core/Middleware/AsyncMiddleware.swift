/// A type that defines async middleware for transforming values.
///
/// The `AsyncMiddleware` protocol is useful for creating composable async processing
/// pipelines that can transform or observe values as they pass through.
///
/// ## Example
/// ```swift
/// struct CachingMiddleware: AsyncMiddleware {
///     var cache: Cache
///
///     func process(_ value: Request) async -> Request {
///         await cache.store(value)
///         return value
///     }
/// }
/// ```
public protocol AsyncMiddleware<Input> {
    associatedtype Input

    /// Processes the given input value asynchronously.
    ///
    /// - Parameter value: The input value to process.
    /// - Returns: The processed value (may be the same or transformed).
    func process(_ value: Input) async -> Input
}
