/// A type-erased async factory wrapper that can store any async factory.
///
/// Use `AnyAsyncFactory` when you need to store async factories with different
/// implementations without exposing their concrete types.
///
/// ## Example
/// ```swift
/// struct AsyncDependencyContainer {
///     var serviceFactory: AnyAsyncFactory<Service>
///
///     func makeService() async -> Service {
///         await serviceFactory.create()
///     }
/// }
///
/// // Production container with network setup
/// let production = AsyncDependencyContainer(
///     serviceFactory: AnyAsyncFactory {
///         let config = try! await fetchRemoteConfig()
///         return Service(config: config)
///     }
/// )
///
/// // Test container with mock
/// let test = AsyncDependencyContainer(
///     serviceFactory: AnyAsyncFactory {
///         Service(config: .mock)
///     }
/// )
/// ```
public struct AnyAsyncFactory<Output>: AsyncFactory {
    @usableFromInline
    let box: () async -> Output

    /// Creates a type-erased async factory from a concrete async factory.
    ///
    /// - Parameter factory: The async factory to wrap.
    @inlinable
    public init<F: AsyncFactory>(_ factory: F) where F.Output == Output {
        self.box = factory.create
    }

    /// Creates a type-erased async factory from a closure.
    ///
    /// - Parameter closure: The async closure that creates instances.
    @inlinable
    public init(_ closure: @escaping () async -> Output) {
        self.box = closure
    }

    /// Creates and returns a new instance asynchronously.
    ///
    /// - Returns: A newly created instance.
    @inlinable
    public func create() async -> Output {
        await box()
    }
}
