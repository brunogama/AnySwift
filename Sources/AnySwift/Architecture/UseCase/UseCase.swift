/// A protocol that defines a use case (interactor) in Clean Architecture.
///
/// Use cases encapsulate business logic and represent a single unit of work
/// that the application can perform.
///
/// ## Example
/// ```swift
/// struct LoginUseCase: UseCase {
///     let authRepository: AnyRepository<User>
///
///     func execute(_ credentials: Credentials) async throws -> User {
///         // Business logic for login
///     }
/// }
/// ```
public protocol UseCase<Input, Output> {
    associatedtype Input
    associatedtype Output

    /// Executes the use case with the given input.
    ///
    /// - Parameter input: The input required to execute the use case.
    /// - Returns: The output of the use case execution.
    /// - Throws: An error if execution fails.
    func execute(_ input: Input) async throws -> Output
}

/// A protocol that defines a use case with no input.
public protocol ParameterlessUseCase<Output> {
    associatedtype Output

    /// Executes the use case.
    ///
    /// - Returns: The output of the use case execution.
    /// - Throws: An error if execution fails.
    func execute() async throws -> Output
}
