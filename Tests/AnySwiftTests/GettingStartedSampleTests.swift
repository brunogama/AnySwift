import Foundation
import Testing

@testable import AnySwift

@Suite("Getting Started Sample Tests")
struct GettingStartedSampleTests {
  @Test("sample composition flow returns pinned items first")
  func sampleCompositionFlowReturnsPinnedItemsFirst() async throws {
    let repository = AnyRepository(InMemoryTodoRepository())
    let makeTodo = AnyFactory { Todo(id: UUID().uuidString, title: "", isPinned: false) }
    let normalizeTitle = AnyMiddleware<String> {
      $0.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    let sortTodos = AnyStrategy<[Todo], [Todo]> { todos in
      todos.sorted { lhs, rhs in
        if lhs.isPinned != rhs.isPinned {
          return lhs.isPinned && !rhs.isPinned
        }

        return lhs.title < rhs.title
      }
    }
    let addTodo = AnyUseCase<String, Todo> { rawTitle in
      var todo = makeTodo.create()
      todo.title = normalizeTitle.process(rawTitle)
      todo.isPinned = todo.title.hasPrefix("!")
      try await repository.save(todo)
      return todo
    }
    let listTodos = AnyQuery<[Todo]> {
      let todos = try await repository.fetchAll()
      return sortTodos.execute(todos)
    }

    _ = try await addTodo.execute("  write docs  ")
    _ = try await addTodo.execute("!ship sample")

    let todos = try await listTodos.execute()
    #expect(todos.map(\.title) == ["!ship sample", "write docs"])
  }
}

private struct Todo: Equatable, Sendable {
  var id: String
  var title: String
  var isPinned: Bool
}

private final class InMemoryTodoRepository: Repository {
  private var storage: [Todo] = []

  func fetchAll() async throws -> [Todo] {
    storage
  }

  func fetchById(_ id: String) async throws -> Todo? {
    storage.first { $0.id == id }
  }

  func save(_ entity: Todo) async throws {
    if let index = storage.firstIndex(where: { $0.id == entity.id }) {
      storage[index] = entity
    } else {
      storage.append(entity)
    }
  }

  func delete(_ entity: Todo) async throws {
    storage.removeAll { $0.id == entity.id }
  }
}
