/// A type that defines a strategy for transforming an input into an output.
///
/// The `Strategy` protocol is useful for encapsulating algorithms or business logic
/// that can be varied at runtime.
///
/// ## Example
/// ```swift
/// struct DiscountStrategy: Strategy {
///     func execute(_ price: Double) -> Double {
///         price * 0.9 // 10% discount
///     }
/// }
/// ```
public protocol Strategy<Input, Output> {
    associatedtype Input
    associatedtype Output

    /// Executes the strategy with the given input.
    ///
    /// - Parameter input: The input value to process.
    /// - Returns: The transformed output value.
    func execute(_ input: Input) -> Output
}
