/// A type-erased factory wrapper that can store any factory conforming to the `Factory` protocol.
///
/// Use `AnyFactory` when you need to store factories with different implementations
/// in a property or collection without exposing their concrete types.
///
/// ## Example
/// ```swift
/// struct DependencyContainer {
///     var viewModelFactory: AnyFactory<ViewModel>
///
///     func makeViewModel() -> ViewModel {
///         viewModelFactory.create()
///     }
/// }
///
/// // Production container
/// let production = DependencyContainer(
///     viewModelFactory: AnyFactory {
///         ViewModel(api: LiveAPIClient())
///     }
/// )
///
/// // Test container
/// let test = DependencyContainer(
///     viewModelFactory: AnyFactory {
///         ViewModel(api: MockAPIClient())
///     }
/// )
/// ```
public struct AnyFactory<Output>: Factory {
    @usableFromInline
    let box: () -> Output

    /// Creates a type-erased factory from a concrete factory.
    ///
    /// - Parameter factory: The factory to wrap.
    @inlinable
    public init<F: Factory>(_ factory: F) where F.Output == Output {
        self.box = factory.create
    }

    /// Creates a type-erased factory from a closure.
    ///
    /// - Parameter closure: The closure that creates instances.
    @inlinable
    public init(_ closure: @escaping () -> Output) {
        self.box = closure
    }

    /// Creates and returns a new instance.
    ///
    /// - Returns: A newly created instance.
    @inlinable
    public func create() -> Output {
        box()
    }
}
