# Commands and Queries

Use these types when you want write operations and read operations to stay explicit, testable, and easy to swap.

## Overview

AnySwift separates action-style work from read-style work:

- ``Command`` and ``AnyCommand`` model behavior that changes state
- ``Query`` and ``AnyQuery`` model behavior that reads state

This works well for CQRS-style boundaries, feature services, and view models that should not know concrete implementation details.

## Commands

### ``AnyCommand``

Wrap a write operation that returns no value.

```swift
let deleteTodo = AnyCommand(
    execute: {
        if let todo = try await repository.fetchById("123") {
            try await repository.delete(todo)
        }
    },
    undo: {
        try await repository.save(Todo(id: "123", title: "Recovered"))
    }
)
```

### ``AnyResultCommand``

Use the result variant when the command should return created or updated data.

```swift
let createTodo = AnyResultCommand<Todo> {
    let todo = Todo(id: UUID().uuidString, title: "Draft")
    try await repository.save(todo)
    return todo
}
```

### ``CommandQueue``

``CommandQueue`` gives you basic undo and redo support for commands that are safe to replay.

```swift
let queue = CommandQueue()
try await queue.execute(deleteTodo)

if queue.canUndo {
    try await queue.undo()
}
```

## Queries

### ``AnyQuery``

Use this for parameterless reads.

```swift
let allTodos = AnyQuery<[Todo]> {
    try await repository.fetchAll()
}
```

### ``AnyParameterizedQuery``

Use this when a read depends on input.

```swift
let todoByID = AnyParameterizedQuery<String, Todo?> { id in
    try await repository.fetchById(id)
}
```

### ``QueryBus``

``QueryBus`` is a lightweight registry for query handlers keyed by result type.

```swift
struct AllTodosQuery: Query {
    func execute() async throws -> [Todo] {
        []
    }
}

let bus = QueryBus()
try bus.register(for: AllTodosQuery.self) {
    try await repository.fetchAll()
}

let todos = try await bus.execute(AllTodosQuery.self)
```

## Choosing the Right Abstraction

Prefer a command when the main job is to change state, trigger side effects, or support undo-like semantics. Prefer a query when the main job is to return information without mutating state. In practice, a feature often uses both:

- use a command to save, delete, import, or sync
- use a query to load, filter, or aggregate data for display

Keeping those paths separate makes tests smaller and dependency injection simpler.
