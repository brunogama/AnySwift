/// A type-erased query wrapper.
///
/// Use `AnyQuery` to work with different query implementations polymorphically.
///
/// ## Example
/// ```swift
/// struct UserViewModel {
///     var getUserQuery: AnyQuery<User?>
///
///     func loadUser() async throws -> User? {
///         try await getUserQuery.execute()
///     }
/// }
/// ```
public struct AnyQuery<Result>: Query {
    @usableFromInline let box: () async throws -> Result

  @inlinable
  public init<Q: Query>(_ query: Q) where Q.Result == Result {
    self.box = query.execute
  }

  @inlinable
  public init(_ closure: @escaping () async throws -> Result) {
    self.box = closure
  }

  @inlinable
  public func execute() async throws -> Result {
    try await box()
  }
}

/// A type-erased parameterized query wrapper.
public struct AnyParameterizedQuery<Input, Result>: ParameterizedQuery {
    @usableFromInline let box: (Input) async throws -> Result

  @inlinable
  public init<Q: ParameterizedQuery>(_ query: Q) where Q.Input == Input, Q.Result == Result {
    self.box = query.execute
  }

  @inlinable
  public init(_ closure: @escaping (Input) async throws -> Result) {
    self.box = closure
  }

  @inlinable
  public func execute(_ input: Input) async throws -> Result {
    try await box(input)
  }
}

/// A query bus that routes queries to appropriate handlers.
public enum QueryBusError: Error, Equatable {
  case duplicateHandler(String)
}

public final class QueryBus {
  private var queryHandlers: [ObjectIdentifier: Any] = [:]
  private var parameterizedQueryHandlers: [ObjectIdentifier: Any] = [:]

  public init() {}

  /// Registers a handler for a specific query type.
  public func register<Q: Query>(
    for queryType: Q.Type,
    handler: @escaping () async throws -> Q.Result
  ) throws {
    let key = ObjectIdentifier(queryType)
    guard queryHandlers[key] == nil else {
      throw QueryBusError.duplicateHandler(String(describing: queryType))
    }
    queryHandlers[key] = handler
  }

  /// Executes a registered query.
  public func execute<Q: Query>(_ type: Q.Type) async throws -> Q.Result? {
    let key = ObjectIdentifier(type)
    guard let handler = queryHandlers[key] as? () async throws -> Q.Result else {
      return nil
    }
    return try await handler()
  }

  /// Registers a handler for a specific parameterized query type.
  public func register<Q: ParameterizedQuery>(
    for queryType: Q.Type,
    handler: @escaping (Q.Input) async throws -> Q.Result
  ) throws {
    let key = ObjectIdentifier(queryType)
    guard parameterizedQueryHandlers[key] == nil else {
      throw QueryBusError.duplicateHandler(String(describing: queryType))
    }
    parameterizedQueryHandlers[key] = handler
  }

  /// Executes a registered parameterized query.
  public func execute<Q: ParameterizedQuery>(
    _ type: Q.Type,
    input: Q.Input
  ) async throws -> Q.Result? {
    let key = ObjectIdentifier(type)
    guard let handler = parameterizedQueryHandlers[key] as? (Q.Input) async throws -> Q.Result
    else {
      return nil
    }
    return try await handler(input)
  }

  /// Clears all registered handlers.
  public func clear() {
    queryHandlers.removeAll()
    parameterizedQueryHandlers.removeAll()
  }
}
