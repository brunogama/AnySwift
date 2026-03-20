/// A type that defines an async factory for creating instances.
///
/// The `AsyncFactory` protocol is useful for encapsulating asynchronous object creation
/// logic that can be varied at runtime, enabling dependency injection with async initialization.
///
/// ## Example
/// ```swift
/// struct AsyncViewModelFactory: AsyncFactory {
///     func create() async throws -> ViewModel {
///         let config = try await fetchConfig()
///         return ViewModel(config: config)
///     }
/// }
/// ```
public protocol AsyncFactory<Output> {
    associatedtype Output

    /// Creates and returns a new instance asynchronously.
    ///
    /// - Returns: A newly created instance.
    func create() async -> Output
}
