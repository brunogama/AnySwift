/// A type-erased repository wrapper.
///
/// Use `AnyRepository` when you need to work with repositories polymorphically,
/// such as in testing or when swapping data layer implementations.
///
/// ## Example
/// ```swift
/// struct UserService {
///     var userRepository: AnyRepository<User>
///
///     func getAllUsers() async throws -> [User] {
///         try await userRepository.fetchAll()
///     }
/// }
///
/// // Production
/// let service = UserService(
///     userRepository: AnyRepository(CoreDataUserRepository())
/// )
///
/// // Testing
/// let mockService = UserService(
///     userRepository: AnyRepository(MockUserRepository())
/// )
/// ```
public struct AnyRepository<Entity>: Repository {
    @usableFromInline
    let fetchAllBox: () async throws -> [Entity]
    @usableFromInline
    let fetchByIdBox: (String) async throws -> Entity?
    @usableFromInline
    let saveBox: (Entity) async throws -> Void
    @usableFromInline
    let deleteBox: (Entity) async throws -> Void

    /// Creates a type-erased repository from a concrete repository.
    ///
    /// - Parameter repository: The repository to wrap.
    @inlinable
    public init<R: Repository>(_ repository: R) where R.Entity == Entity {
        self.fetchAllBox = repository.fetchAll
        self.fetchByIdBox = repository.fetchById
        self.saveBox = repository.save
        self.deleteBox = repository.delete
    }

    /// Creates a type-erased repository from closures.
    ///
    /// - Parameters:
    ///   - fetchAll: Closure to fetch all entities.
    ///   - fetchById: Closure to fetch an entity by ID.
    ///   - save: Closure to save an entity.
    ///   - delete: Closure to delete an entity.
    @inlinable
    public init(
        fetchAll: @escaping () async throws -> [Entity],
        fetchById: @escaping (String) async throws -> Entity?,
        save: @escaping (Entity) async throws -> Void,
        delete: @escaping (Entity) async throws -> Void
    ) {
        self.fetchAllBox = fetchAll
        self.fetchByIdBox = fetchById
        self.saveBox = save
        self.deleteBox = delete
    }

    @inlinable
    public func fetchAll() async throws -> [Entity] {
        try await fetchAllBox()
    }

    @inlinable
    public func fetchById(_ id: String) async throws -> Entity? {
        try await fetchByIdBox(id)
    }

    @inlinable
    public func save(_ entity: Entity) async throws {
        try await saveBox(entity)
    }

    @inlinable
    public func delete(_ entity: Entity) async throws {
        try await deleteBox(entity)
    }
}
