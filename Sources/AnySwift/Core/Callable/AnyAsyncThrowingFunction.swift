/// A type-erased async throwing function wrapper that can store any async function
/// taking `Input` and returning `Output` that may throw an error.
///
/// Use `AnyAsyncThrowingFunction` when you need to store async throwing functions
/// with different implementations without exposing their concrete types.
///
/// ## Example
/// ```swift
/// struct APIClient {
///     var request: AnyAsyncThrowingFunction<Request, Response>
/// }
///
/// // Production
/// let production = APIClient(
///     request: AnyAsyncThrowingFunction { request in
///         let (data, response) = try await URLSession.shared.data(for: request)
///         guard let httpResponse = response as? HTTPURLResponse,
///               httpResponse.statusCode == 200 else {
///             throw APIError.invalidResponse
///         }
///         return try JSONDecoder().decode(Response.self, from: data)
///     }
/// )
///
/// // Testing with failure
/// let testingFailure = APIClient(
///     request: AnyAsyncThrowingFunction { _ in
///         throw APIError.networkFailure
///     }
/// )
/// ```
public struct AnyAsyncThrowingFunction<Input, Output>: AsyncThrowingCallable {
    @usableFromInline
    let box: (Input) async throws -> Output

    /// Creates a type-erased async throwing function from a function or closure.
    ///
    /// - Parameter function: The async throwing function or closure to wrap.
    @inlinable
    public init(_ function: @escaping (Input) async throws -> Output) {
        self.box = function
    }

    /// Calls the underlying function with the given input.
    ///
    /// - Parameter input: The input value to pass to the function.
    /// - Returns: The output value from the function.
    /// - Throws: Any error thrown by the underlying function.
    @inlinable
    public func callAsFunction(_ input: Input) async throws -> Output {
        try await box(input)
    }
}

/// A protocol that defines an async throwing callable type.
///
/// Types conforming to `AsyncThrowingCallable` can be called like functions using
/// the `callAsFunction` syntax, support async/await, and may throw errors.
public protocol AsyncThrowingCallable<Input, Output> {
    associatedtype Input
    associatedtype Output

    /// Calls the callable with the given input asynchronously, potentially throwing an error.
    func callAsFunction(_ input: Input) async throws -> Output
}
