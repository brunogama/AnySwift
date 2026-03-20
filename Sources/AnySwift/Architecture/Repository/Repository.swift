/// A protocol that defines a repository for accessing and managing domain entities.
///
/// The `Repository` protocol is central to Clean Architecture, providing an abstraction
/// over data storage mechanisms. It allows the domain layer to remain independent of
/// data access details.
///
/// ## Example
/// ```swift
/// protocol UserRepository: Repository {
///     func findByEmail(_ email: String) async throws -> User?
///     func save(_ user: User) async throws
/// }
/// ```
public protocol Repository<Entity> {
    associatedtype Entity

    /// Fetches all entities from the repository.
    ///
    /// - Returns: An array of all entities.
    /// - Throws: An error if the fetch fails.
    func fetchAll() async throws -> [Entity]

    /// Fetches an entity by its identifier.
    ///
    /// - Parameter id: The unique identifier of the entity.
    /// - Returns: The entity if found, or `nil`.
    /// - Throws: An error if the fetch fails.
    func fetchById(_ id: String) async throws -> Entity?

    /// Saves an entity to the repository.
    ///
    /// - Parameter entity: The entity to save.
    /// - Throws: An error if the save fails.
    func save(_ entity: Entity) async throws

    /// Deletes an entity from the repository.
    ///
    /// - Parameter entity: The entity to delete.
    /// - Throws: An error if the deletion fails.
    func delete(_ entity: Entity) async throws
}
