/// A type that defines a factory for creating instances.
///
/// The `Factory` protocol is useful for encapsulating object creation logic
/// that can be varied at runtime, enabling dependency injection and testing.
///
/// ## Example
/// ```swift
/// struct ViewModelFactory: Factory {
///     func create() -> ViewModel {
///         ViewModel(dependencies: .production)
///     }
/// }
/// ```
public protocol Factory<Output> {
    associatedtype Output

    /// Creates and returns a new instance.
    ///
    /// - Returns: A newly created instance.
    func create() -> Output
}
