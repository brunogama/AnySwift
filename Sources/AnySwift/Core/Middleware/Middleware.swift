/// A type that defines middleware for transforming values.
///
/// The `Middleware` protocol is useful for creating composable processing pipelines
/// that can transform or observe values as they pass through.
///
/// ## Example
/// ```swift
/// struct LoggingMiddleware: Middleware {
///     func process(_ value: Request) -> Request {
///         print("Processing: \(value)")
///         return value
///     }
/// }
/// ```
public protocol Middleware<Input> {
    associatedtype Input

    /// Processes the given input value.
    ///
    /// - Parameter value: The input value to process.
    /// - Returns: The processed value (may be the same or transformed).
    func process(_ value: Input) -> Input
}
