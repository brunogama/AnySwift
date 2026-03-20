/// A type-erased throwing function wrapper that can store any function taking `Input`
/// and returning `Output` that may throw an error.
///
/// Use `AnyThrowingFunction` when you need to store throwing functions with different
/// implementations without exposing their concrete types.
///
/// ## Example
/// ```swift
/// var validators: [AnyThrowingFunction<String, String>] = [
///     AnyThrowingFunction { input in
///         guard !input.isEmpty else { throw ValidationError.empty }
///         return input
///     },
///     AnyThrowingFunction { input in
///         guard input.count >= 8 else { throw ValidationError.tooShort }
///         return input
///     }
/// ]
///
/// for validator in validators {
///     do {
///         _ = try validator("test")
///     } catch {
///         print("Validation failed: \(error)")
///     }
/// }
/// ```
public struct AnyThrowingFunction<Input, Output>: ThrowingCallable {
    @usableFromInline
    let box: (Input) throws -> Output

    /// Creates a type-erased throwing function from a function or closure.
    ///
    /// - Parameter function: The throwing function or closure to wrap.
    @inlinable
    public init(_ function: @escaping (Input) throws -> Output) {
        self.box = function
    }

    /// Calls the underlying function with the given input.
    ///
    /// - Parameter input: The input value to pass to the function.
    /// - Returns: The output value from the function.
    /// - Throws: Any error thrown by the underlying function.
    @inlinable
    public func callAsFunction(_ input: Input) throws -> Output {
        try box(input)
    }
}

/// A protocol that defines a throwing callable type.
///
/// Types conforming to `ThrowingCallable` can be called like functions using
/// the `callAsFunction` syntax and may throw errors.
public protocol ThrowingCallable<Input, Output> {
    associatedtype Input
    associatedtype Output

    /// Calls the callable with the given input, potentially throwing an error.
    func callAsFunction(_ input: Input) throws -> Output
}
