/// A protocol that defines a query in CQRS (Command Query Responsibility Segregation).
///
/// Queries are used to retrieve data without modifying state.
///
/// ## Example
/// ```swift
/// struct GetUserByIdQuery: Query {
///     let userId: String
///     let repository: AnyRepository<User>
///
///     func execute() async throws -> User? {
///         try await repository.fetchById(userId)
///     }
/// }
/// ```
public protocol Query<Result> {
    associatedtype Result

    /// Executes the query and returns the result.
    ///
    /// - Returns: The query result.
    /// - Throws: An error if the query fails.
    func execute() async throws -> Result
}

/// A protocol for queries that take input parameters.
public protocol ParameterizedQuery<Input, Result> {
    associatedtype Input
    associatedtype Result

    /// Executes the query with the given input.
    ///
    /// - Parameter input: The query input parameters.
    /// - Returns: The query result.
    /// - Throws: An error if the query fails.
    func execute(_ input: Input) async throws -> Result
}
