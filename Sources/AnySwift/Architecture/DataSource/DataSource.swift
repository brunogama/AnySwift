/// A protocol that defines a data source for retrieving data.
///
/// Data sources represent the origin of data (local, remote, etc.) in Clean Architecture.
public protocol DataSource<Entity> {
    associatedtype Entity

    /// Retrieves all entities from the data source.
    func getAll() async throws -> [Entity]

    /// Retrieves an entity by ID.
    func getById(_ id: String) async throws -> Entity?

    /// Saves an entity to the data source.
    func add(_ entity: Entity) async throws

    /// Updates an entity in the data source.
    func update(_ entity: Entity) async throws

    /// Removes an entity from the data source.
    func remove(_ entity: Entity) async throws
}

/// A protocol for local data sources.
public protocol LocalDataSource<Entity>: DataSource {
    /// Clears all data from the local source.
    func clearAll() async throws
}

/// A protocol for remote data sources.
public protocol RemoteDataSource<Entity>: DataSource {
    /// Checks if the remote source is reachable.
    var isReachable: Bool { get }
}
