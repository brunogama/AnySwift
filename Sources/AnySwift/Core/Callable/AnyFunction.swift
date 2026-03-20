/// A type-erased function wrapper that can store any function taking `Input` and returning `Output`.
///
/// Use `AnyFunction` when you need to store functions with different implementations
/// in a property or collection without exposing their concrete types.
///
/// ## Example
/// ```swift
/// var operations: [AnyFunction<Int, Int>] = [
///     AnyFunction { $0 * 2 },
///     AnyFunction { $0 + 10 },
///     AnyFunction { $0 * $0 }
/// ]
///
/// let results = operations.map { $0(5) } // [10, 15, 25]
/// ```
public struct AnyFunction<Input, Output>: Callable {
    @usableFromInline
    let box: (Input) -> Output

    /// Creates a type-erased function from a function or closure.
    ///
    /// - Parameter function: The function or closure to wrap.
    @inlinable
    public init(_ function: @escaping (Input) -> Output) {
        self.box = function
    }

    /// Calls the underlying function with the given input.
    ///
    /// - Parameter input: The input value to pass to the function.
    /// - Returns: The output value from the function.
    @inlinable
    public func callAsFunction(_ input: Input) -> Output {
        box(input)
    }
}

/// A protocol that defines a callable type.
///
/// Types conforming to `Callable` can be called like functions using
/// the `callAsFunction` syntax.
public protocol Callable<Input, Output> {
    associatedtype Input
    associatedtype Output

    /// Calls the callable with the given input.
    func callAsFunction(_ input: Input) -> Output
}
