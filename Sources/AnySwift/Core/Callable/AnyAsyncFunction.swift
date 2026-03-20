/// A type-erased async function wrapper that can store any async function taking `Input`
/// and returning `Output`.
///
/// Use `AnyAsyncFunction` when you need to store async functions with different
/// implementations without exposing their concrete types.
///
/// ## Example
/// ```swift
/// struct DataLoader {
///     var fetch: AnyAsyncFunction<URL, Data>
/// }
///
/// // Production
/// let production = DataLoader(
///     fetch: AnyAsyncFunction { url in
///         try await URLSession.shared.data(from: url).0
///     }
/// )
///
/// // Testing
/// let testing = DataLoader(
///     fetch: AnyAsyncFunction { _ in
///         try await Task.sleep(nanoseconds: 100_000_000)
///         return Data("test".utf8)
///     }
/// )
/// ```
public struct AnyAsyncFunction<Input, Output>: AsyncCallable {
    @usableFromInline
    let box: (Input) async -> Output

    /// Creates a type-erased async function from a function or closure.
    ///
    /// - Parameter function: The async function or closure to wrap.
    @inlinable
    public init(_ function: @escaping (Input) async -> Output) {
        self.box = function
    }

    /// Calls the underlying function with the given input.
    ///
    /// - Parameter input: The input value to pass to the function.
    /// - Returns: The output value from the function.
    @inlinable
    public func callAsFunction(_ input: Input) async -> Output {
        await box(input)
    }
}

/// A protocol that defines an async callable type.
///
/// Types conforming to `AsyncCallable` can be called like functions using
/// the `callAsFunction` syntax and support async/await.
public protocol AsyncCallable<Input, Output> {
    associatedtype Input
    associatedtype Output

    /// Calls the callable with the given input asynchronously.
    func callAsFunction(_ input: Input) async -> Output
}
