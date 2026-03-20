# Architecture

Use these types when you want to keep domain and presentation layers generic while still storing them in properties, dependency containers, and test fixtures.

## Overview

AnySwift includes a small set of Clean Architecture and MVP-friendly abstractions. The protocols model the role of each layer, and the `Any*` wrappers let you pass those abstractions around without leaking concrete types.

## Data Access

Use ``DataSource`` when you want to model the origin of data directly. Use ``Repository`` when you want a domain-facing abstraction that hides storage details.

### ``AnyDataSource``

Wrap a concrete source behind one async CRUD interface.

```swift
struct TodoDTO: Sendable {
    let id: String
    let title: String
}

let remote = AnyDataSource<TodoDTO>(
    getAll: { try await api.fetchTodos() },
    getById: { id in try await api.fetchTodo(id: id) },
    add: { todo in try await api.create(todo) },
    update: { todo in try await api.update(todo) },
    remove: { todo in try await api.delete(id: todo.id) }
)
```

### ``AnyLocalDataSource`` and ``AnyRemoteDataSource``

Use the specialized wrappers when your code needs local-only or remote-only capabilities such as `clearAll()` or `isReachable`.

```swift
let local = AnyLocalDataSource(FileTodoCache())
let remote = AnyRemoteDataSource(HTTPTodoAPI())

if remote.isReachable {
    let todos = try await remote.getAll()
    try await local.clearAll()
    for todo in todos {
        try await local.add(todo)
    }
}
```

### ``AnyRepository``

Use a repository when the caller should think in domain entities instead of transport or persistence details.

```swift
struct Todo: Sendable, Equatable {
    let id: String
    var title: String
}

struct TodoService {
    let repository: AnyRepository<Todo>

    func todo(id: String) async throws -> Todo? {
        try await repository.fetchById(id)
    }
}
```

## Use Cases

Use cases package business operations behind one stable async entry point.

### ``AnyUseCase``

Use this for operations that need input.

```swift
let renameTodo = AnyUseCase<(String, String), Todo> { id, newTitle in
    guard var todo = try await repository.fetchById(id) else {
        throw TodoError.notFound
    }

    todo.title = newTitle
    try await repository.save(todo)
    return todo
}
```

### ``AnyParameterlessUseCase``

Use this for bootstrapping or refresh flows that do not take arguments.

```swift
let refreshTodos = AnyParameterlessUseCase<[Todo]> {
    try await repository.fetchAll()
}
```

## Presentation

``Presenter`` models view lifecycle hooks in MVP-style flows, and ``AnyPresenter`` makes that abstraction easy to inject.

```swift
struct TodoScreen {
    var presenter: AnyPresenter

    func viewDidLoad() {
        presenter.viewDidLoad()
    }
}
```

## Typical Layering

One common shape is:

- a ``RemoteDataSource`` talks to the network
- a ``LocalDataSource`` handles offline storage
- a ``Repository`` exposes domain entities
- a ``UseCase`` applies business rules
- a ``Presenter`` reacts to the screen lifecycle

That is enough to keep app code modular without forcing the whole codebase into generics.
