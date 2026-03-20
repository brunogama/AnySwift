/// A type-erased use case wrapper.
///
/// Use `AnyUseCase` to store and execute use cases polymorphically.
///
/// ## Example
/// ```swift
/// class UserViewModel {
///     var loginUseCase: AnyUseCase<Credentials, User>
///
///     func login(credentials: Credentials) async {
///         do {
///             let user = try await loginUseCase.execute(credentials)
///             // Handle success
///         } catch {
///             // Handle error
///         }
///     }
/// }
///
/// // Production
/// let viewModel = UserViewModel(
///     loginUseCase: AnyUseCase(LoginUseCase(repository: userRepo))
/// )
///
/// // Testing
/// let mockViewModel = UserViewModel(
///     loginUseCase: AnyUseCase { _ in MockUser() }
/// )
/// ```
public struct AnyUseCase<Input, Output>: UseCase {
    @usableFromInline
    let box: (Input) async throws -> Output

    /// Creates a type-erased use case from a concrete use case.
    ///
    /// - Parameter useCase: The use case to wrap.
    @inlinable
    public init<U: UseCase>(_ useCase: U) where U.Input == Input, U.Output == Output {
        self.box = useCase.execute
    }

    /// Creates a type-erased use case from a closure.
    ///
    /// - Parameter closure: The closure that implements the use case logic.
    @inlinable
    public init(_ closure: @escaping (Input) async throws -> Output) {
        self.box = closure
    }

    @inlinable
    public func execute(_ input: Input) async throws -> Output {
        try await box(input)
    }
}

/// A type-erased parameterless use case wrapper.
public struct AnyParameterlessUseCase<Output>: ParameterlessUseCase {
    @usableFromInline
    let box: () async throws -> Output

    /// Creates a type-erased use case from a concrete use case.
    ///
    /// - Parameter useCase: The use case to wrap.
    @inlinable
    public init<U: ParameterlessUseCase>(_ useCase: U) where U.Output == Output {
        self.box = useCase.execute
    }

    /// Creates a type-erased use case from a closure.
    ///
    /// - Parameter closure: The closure that implements the use case logic.
    @inlinable
    public init(_ closure: @escaping () async throws -> Output) {
        self.box = closure
    }

    @inlinable
    public func execute() async throws -> Output {
        try await box()
    }
}
