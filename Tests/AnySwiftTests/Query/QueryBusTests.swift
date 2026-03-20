import Testing

@testable import AnySwift

@Suite("QueryBus Tests")
struct QueryBusTests {
  @Test("routes multiple query types with the same result type")
  func routesMultipleQueryTypesWithTheSameResultType() async throws {
    let bus = QueryBus()

    try bus.register(for: FirstQuery.self) { "first" }
    try bus.register(for: SecondQuery.self) { "second" }

    let first = try await bus.execute(FirstQuery.self)
    let second = try await bus.execute(SecondQuery.self)

    #expect(first == "first")
    #expect(second == "second")
  }

  @Test("routes parameterized query handlers by query type")
  func routesParameterizedQueryHandlersByQueryType() async throws {
    let bus = QueryBus()

    try bus.register(for: LookupQuery.self) { input in
      "value: \(input)"
    }

    let result = try await bus.execute(LookupQuery.self, input: "abc")
    #expect(result == "value: abc")
  }

  @Test("rejects duplicate query registrations")
  func rejectsDuplicateQueryRegistrations() throws {
    let bus = QueryBus()
    try bus.register(for: FirstQuery.self) { "first" }

    #expect(throws: QueryBusError.duplicateHandler(String(describing: FirstQuery.self))) {
      try bus.register(for: FirstQuery.self) { "second" }
    }
  }
}

private struct FirstQuery: Query {
  func execute() async throws -> String {
    ""
  }
}

private struct SecondQuery: Query {
  func execute() async throws -> String {
    ""
  }
}

private struct LookupQuery: ParameterizedQuery {
  func execute(_ input: String) async throws -> String {
    input
  }
}
