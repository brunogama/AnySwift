/// A type-erased strategy wrapper that can store any strategy conforming to the `Strategy` protocol.
///
/// Use `AnyStrategy` when you need to store strategies with different implementations
/// in a property or collection without exposing their concrete types.
///
/// ## Example
/// ```swift
/// struct PricingEngine {
///     var strategy: AnyStrategy<Double, Double>
///
///     func calculatePrice(_ basePrice: Double) -> Double {
///         strategy.execute(basePrice)
///     }
/// }
///
/// // Regular price
/// let regular = PricingEngine(strategy: AnyStrategy { $0 })
///
/// // 10% discount
/// let discount = PricingEngine(strategy: AnyStrategy { $0 * 0.9 })
///
/// // Buy one get one half off
/// let bogo = PricingEngine(strategy: AnyStrategy { $0 * 1.5 })
/// ```
public struct AnyStrategy<Input, Output>: Strategy {
    @usableFromInline
    let box: (Input) -> Output

    /// Creates a type-erased strategy from a concrete strategy.
    ///
    /// - Parameter strategy: The strategy to wrap.
    @inlinable
    public init<S: Strategy>(_ strategy: S) where S.Input == Input, S.Output == Output {
        self.box = strategy.execute
    }

    /// Creates a type-erased strategy from a closure.
    ///
    /// - Parameter closure: The closure that implements the strategy logic.
    @inlinable
    public init(_ closure: @escaping (Input) -> Output) {
        self.box = closure
    }

    /// Executes the strategy with the given input.
    ///
    /// - Parameter input: The input value to process.
    /// - Returns: The transformed output value.
    @inlinable
    public func execute(_ input: Input) -> Output {
        box(input)
    }
}
