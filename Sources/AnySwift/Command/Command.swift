/// A protocol that defines a command in the Command pattern.
///
/// Commands encapsulate actions and their parameters, allowing for
/// parameterization of clients with queues, requests, and operations.
///
/// ## Example
/// ```swift
/// struct DeleteUserCommand: Command {
///     let userId: String
///     let repository: AnyRepository<User>
///
///     func execute() async throws {
///         if let user = try await repository.fetchById(userId) {
///             try await repository.delete(user)
///         }
///     }
///
///     func undo() async throws {
///         // Implementation for undoing the delete
///     }
/// }
/// ```
public protocol Command {
    /// Executes the command.
    func execute() async throws

    /// Undoes the command (optional).
    func undo() async throws

    /// Returns whether the command can be executed.
    var canExecute: Bool { get }
}

extension Command {
    /// Default implementation of undo (no-op).
    public func undo() async throws {}

    /// Default implementation: commands can be executed.
    public var canExecute: Bool { true }
}

/// A protocol for commands that return a result.
public protocol ResultCommand<Result> {
    associatedtype Result

    /// Executes the command and returns a result.
    func execute() async throws -> Result

    /// Undoes the command (optional).
    func undo() async throws

    /// Returns whether the command can be executed.
    var canExecute: Bool { get }
}

extension ResultCommand {
    public func undo() async throws {}
    public var canExecute: Bool { true }
}
