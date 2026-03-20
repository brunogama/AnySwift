# Factory Pattern

Type-erased wrappers for object creation patterns.

## Overview

The Factory pattern encapsulates object creation logic, making it easy to swap implementations for testing or different environments.

## Types

### ``AnyFactory``

A type-erased factory for synchronous object creation.

```swift
struct DependencyContainer {
    var viewModelFactory: AnyFactory<ViewModel>

    func makeViewModel() -> ViewModel {
        viewModelFactory.create()
    }
}

// Production
let production = DependencyContainer(
    viewModelFactory: AnyFactory {
        ViewModel(api: LiveAPIClient())
    }
)

// Testing
let test = DependencyContainer(
    viewModelFactory: AnyFactory {
        ViewModel(api: MockAPIClient())
    }
)
```

### ``AnyAsyncFactory``

A type-erased factory for asynchronous object creation.

```swift
struct AsyncDependencyContainer {
    var serviceFactory: AnyAsyncFactory<Service>

    func makeService() async -> Service {
        await serviceFactory.create()
    }
}

// Production with async setup
let production = AsyncDependencyContainer(
    serviceFactory: AnyAsyncFactory {
        let config = try! await fetchRemoteConfig()
        return Service(config: config)
    }
)

// Testing
let test = AsyncDependencyContainer(
    serviceFactory: AnyAsyncFactory {
        Service(config: .mock)
    }
)
```

## Use Cases

### View Model Creation

Abstract view model creation for different contexts:

```swift
protocol ViewModelFactory {
    associatedtype ViewModel
    func create() -> ViewModel
}

class ViewController {
    var factory: AnyFactory<MyViewModel>

    init(factory: AnyFactory<MyViewModel>) {
        self.factory = factory
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let viewModel = factory.create()
        // Configure with viewModel
    }
}
```

### Service Locator

Build a service locator with type-erased factories:

```swift
class ServiceLocator {
    private var factories: [String: AnyFactory<Any>] = [:]

    func register<T>(_ type: T.Type, factory: AnyFactory<T>) {
        factories[String(describing: type)] = AnyFactory { factory.create() }
    }

    func resolve<T>(_ type: T.Type) -> T? {
        factories[String(describing: type)]?.create() as? T
    }
}

// Usage
let locator = ServiceLocator()
locator.register(APIClient.self, factory: AnyFactory { LiveAPIClient() })

let client: APIClient? = locator.resolve(APIClient.self)
```

### Async Resource Initialization

Handle async setup with AnyAsyncFactory:

```swift
struct DatabaseManager {
    var databaseFactory: AnyAsyncFactory<Database>

    func setup() async throws -> Database {
        let db = await databaseFactory.create()
        try await db.migrate()
        return db
    }
}

let manager = DatabaseManager(
    databaseFactory: AnyAsyncFactory {
        let db = Database(path: ":memory:")
        try? await db.open()
        return db
    }
)
```
