/// A type-erased data source wrapper.
///
/// Use `AnyDataSource` to abstract over different data source implementations.
public struct AnyDataSource<Entity>: DataSource {
    @usableFromInline
    let getAllBox: () async throws -> [Entity]
    @usableFromInline
    let getByIdBox: (String) async throws -> Entity?
    @usableFromInline
    let addBox: (Entity) async throws -> Void
    @usableFromInline
    let updateBox: (Entity) async throws -> Void
    @usableFromInline
    let removeBox: (Entity) async throws -> Void

    @inlinable
    public init<D: DataSource>(_ dataSource: D) where D.Entity == Entity {
        self.getAllBox = dataSource.getAll
        self.getByIdBox = dataSource.getById
        self.addBox = dataSource.add
        self.updateBox = dataSource.update
        self.removeBox = dataSource.remove
    }

    @inlinable
    public init(
        getAll: @escaping () async throws -> [Entity],
        getById: @escaping (String) async throws -> Entity?,
        add: @escaping (Entity) async throws -> Void,
        update: @escaping (Entity) async throws -> Void,
        remove: @escaping (Entity) async throws -> Void
    ) {
        self.getAllBox = getAll
        self.getByIdBox = getById
        self.addBox = add
        self.updateBox = update
        self.removeBox = remove
    }

    @inlinable
    public func getAll() async throws -> [Entity] {
        try await getAllBox()
    }

    @inlinable
    public func getById(_ id: String) async throws -> Entity? {
        try await getByIdBox(id)
    }

    @inlinable
    public func add(_ entity: Entity) async throws {
        try await addBox(entity)
    }

    @inlinable
    public func update(_ entity: Entity) async throws {
        try await updateBox(entity)
    }

    @inlinable
    public func remove(_ entity: Entity) async throws {
        try await removeBox(entity)
    }
}

/// A type-erased local data source wrapper.
public struct AnyLocalDataSource<Entity>: LocalDataSource {
    @usableFromInline
    let getAllBox: () async throws -> [Entity]
    @usableFromInline
    let getByIdBox: (String) async throws -> Entity?
    @usableFromInline
    let addBox: (Entity) async throws -> Void
    @usableFromInline
    let updateBox: (Entity) async throws -> Void
    @usableFromInline
    let removeBox: (Entity) async throws -> Void
    @usableFromInline
    let clearAllBox: () async throws -> Void

    @inlinable
    public init<D: LocalDataSource>(_ dataSource: D) where D.Entity == Entity {
        self.getAllBox = dataSource.getAll
        self.getByIdBox = dataSource.getById
        self.addBox = dataSource.add
        self.updateBox = dataSource.update
        self.removeBox = dataSource.remove
        self.clearAllBox = dataSource.clearAll
    }

    @inlinable
    public func getAll() async throws -> [Entity] {
        try await getAllBox()
    }

    @inlinable
    public func getById(_ id: String) async throws -> Entity? {
        try await getByIdBox(id)
    }

    @inlinable
    public func add(_ entity: Entity) async throws {
        try await addBox(entity)
    }

    @inlinable
    public func update(_ entity: Entity) async throws {
        try await updateBox(entity)
    }

    @inlinable
    public func remove(_ entity: Entity) async throws {
        try await removeBox(entity)
    }

    @inlinable
    public func clearAll() async throws {
        try await clearAllBox()
    }
}

/// A type-erased remote data source wrapper.
public struct AnyRemoteDataSource<Entity>: RemoteDataSource {
    @usableFromInline
    let getAllBox: () async throws -> [Entity]
    @usableFromInline
    let getByIdBox: (String) async throws -> Entity?
    @usableFromInline
    let addBox: (Entity) async throws -> Void
    @usableFromInline
    let updateBox: (Entity) async throws -> Void
    @usableFromInline
    let removeBox: (Entity) async throws -> Void
    @usableFromInline
    let isReachableBox: () -> Bool

    @inlinable
    public init<D: RemoteDataSource>(_ dataSource: D) where D.Entity == Entity {
        self.getAllBox = dataSource.getAll
        self.getByIdBox = dataSource.getById
        self.addBox = dataSource.add
        self.updateBox = dataSource.update
        self.removeBox = dataSource.remove
        self.isReachableBox = { dataSource.isReachable }
    }

    @inlinable
    public func getAll() async throws -> [Entity] {
        try await getAllBox()
    }

    @inlinable
    public func getById(_ id: String) async throws -> Entity? {
        try await getByIdBox(id)
    }

    @inlinable
    public func add(_ entity: Entity) async throws {
        try await addBox(entity)
    }

    @inlinable
    public func update(_ entity: Entity) async throws {
        try await updateBox(entity)
    }

    @inlinable
    public func remove(_ entity: Entity) async throws {
        try await removeBox(entity)
    }

    @inlinable
    public var isReachable: Bool {
        isReachableBox()
    }
}
