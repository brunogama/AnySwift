# Getting Started

Start here if you want one realistic example that shows why AnySwift exists.

## Why this package helps

Swift protocols with associated types or `Self` requirements are great for modeling behavior, but they are awkward to store in properties, collections, and dependency containers. AnySwift gives you stable wrappers so you can keep those abstractions while still building composable application code.

## A Small Todo Flow

This example combines a repository, a factory, a middleware step, a use case, a query, and a sorting strategy.

```swift
import AnySwift
import Foundation

struct Todo: Sendable, Equatable {
    var id: String
    var title: String
    var isPinned: Bool
}

final class InMemoryTodoRepository: Repository {
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
print(todos.map(\.title)) // ["!ship sample", "write docs"]
```

## What to notice

- `AnyRepository` keeps the feature dependent on the repository contract instead of the concrete implementation.
- `AnyFactory` gives the write flow a replaceable creation strategy.
- `AnyMiddleware` is a lightweight place to normalize or enrich inputs before saving.
- `AnyUseCase` packages the mutation path behind one async function-like interface.
- `AnyQuery` keeps reads explicit and composable.
- `AnyStrategy` lets you swap presentation logic without touching the write path.

## Next steps

- Read <doc:Callable> for function-style wrappers.
- Read <doc:Strategy> for strategies and predicates.
- Read <doc:Factory> for sync and async construction.
- Read <doc:Middleware> for pipeline composition.
- Browse ``AnyRepository``, ``AnyUseCase``, ``AnyQuery``, and ``AnyCommand`` for app-level patterns.
