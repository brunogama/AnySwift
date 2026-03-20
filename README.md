# AnySwift

Type-erased building blocks for Swift apps, workflows, and architecture layers.

## Overview

AnySwift collects reusable wrappers for protocols and generic abstractions that are hard to store directly in Swift. It covers both low-level composition tools like functions, factories, strategies, and middleware, plus higher-level app patterns such as repositories, use cases, queries, commands, stores, routers, loggers, and validators.

## Package Highlights

- Callable wrappers: `AnyFunction`, `AnyThrowingFunction`, `AnyAsyncFunction`, `AnyAsyncThrowingFunction`
- Composition tools: `AnyStrategy`, `AnyPredicate`, `AnyFactory`, `AnyAsyncFactory`, `AnyMiddleware`, `AnyAsyncMiddleware`
- Async utilities: `AnyCancellation`, `AnyAsyncSequence`, `AnyAsyncIterator`
- App architecture: `AnyRepository`, `AnyUseCase`, `AnyQuery`, `AnyCommand`, `CommandQueue`
- App infrastructure: `AnyStore`, `AnyObserver`, `AnyRouter`, `AnyLogger`, `AnyMapper`, `AnyValidator`, `AnyCache`

## Getting Started Sample

This sample shows how the wrappers fit together in one small flow instead of isolated one-liners.

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

What each wrapper is doing:

- `AnyFactory` creates a neutral default value without exposing creation details.
- `AnyMiddleware` normalizes input before it becomes domain state.
- `AnyUseCase` hides the concrete write workflow behind one async interface.
- `AnyQuery` models reads separately from writes.
- `AnyStrategy` keeps presentation ordering swappable at runtime.
- `AnyRepository` lets the feature depend on the abstraction instead of the concrete repository type.

## Installation

For a local checkout:

```swift
dependencies: [
    .package(path: "../AnySwift")
]
```

If you publish the package, replace the local path with your remote URL.

## Documentation

DocC lives in `Sources/AnySwift/Documentation.docc`.

- Start with the `Getting Started` article for the end-to-end sample.
- Use the pattern guides for callable, strategy, factory, middleware, and async sequence wrappers.
- Use the architecture guides for repositories, data sources, use cases, presenters, commands, and queries.
- Use the support guides for stores, observers, logging, caching, mapping, validation, routing, and coordination.

## Repository Layout

```text
AnySwift/
├── Package.swift
├── README.md
├── Sources/AnySwift
└── Tests/AnySwiftTests
```

## Platform Support

- iOS 13.0+
- macOS 10.15+
- tvOS 13.0+
- watchOS 6.0+
- macCatalyst 13.0+

## Validation

```bash
swift test
```
