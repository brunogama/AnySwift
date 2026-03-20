# Support Utilities

Use these utilities when a feature needs small, swappable collaborators around logging, caching, mapping, validation, routing, and coordination.

## Logging

``Logger`` defines the contract. ``AnyLogger`` erases concrete implementations and adds convenience methods like `debug`, `info`, `warning`, `error`, and `critical`.

```swift
let logger = AnyLogger(ConsoleLogger(minLevel: .info))
logger.info("Starting sync")
logger.error("Sync failed")
```

Use ``CompositeLogger`` when the same event should go to multiple sinks.

```swift
let logger = CompositeLogger(
    loggers: [
        AnyLogger(ConsoleLogger()),
        AnyLogger { message, level, _, _, _ in
            analytics.record(level: level.name, message: message)
        }
    ]
)
```

## Caching

``Cache`` defines a synchronous key-value interface. ``AnyCache`` lets you inject different implementations without exposing their storage details, and ``ThreadSafeCache`` adds a locking wrapper.

```swift
var storage: [String: Data] = [:]

let cache = AnyCache<String, Data>(
    get: { storage[$0] },
    set: { value, key in storage[key] = value },
    remove: { storage.removeValue(forKey: $0) },
    clear: { storage.removeAll() },
    contains: { storage[$0] != nil }
)
```

## Mapping

Use ``Mapper`` and ``AnyMapper`` when you want explicit transformations between layers, such as DTO-to-domain or domain-to-view conversions.

```swift
struct TodoRow {
    let id: String
    let title: String
}

let mapper = AnyMapper<TodoRow, Todo> {
    Todo(id: $0.id, title: $0.title, isPinned: false)
}

let todos = mapper.mapCollection(rows)
```

Async transformations use ``AsyncMapper`` and ``AnyAsyncMapper``.

## Validation

Use ``Validator`` and ``AnyValidator`` for reusable rules. ``ValidationResult`` keeps success and failure explicit, and ``CompositeValidator`` lets you bundle rule sets.

```swift
let notEmpty = AnyValidator<String> {
    $0.isEmpty ? .invalid("Title is required") : .valid
}

let shortEnough = AnyValidator<String> {
    $0.count <= 80 ? .valid : .invalid("Title is too long")
}

let validator = CompositeValidator(validators: [notEmpty, shortEnough])
```

## Routing and Coordination

Use ``Router`` and ``AnyRouter`` when a feature should trigger navigation without depending on UIKit, SwiftUI coordinators, or concrete screen types.

```swift
let router = AnyRouter(
    navigate: { route in print("push:", route) },
    present: { route in print("present:", route) },
    dismiss: { print("dismiss") },
    goBack: { print("back") },
    goToRoot: { print("root") }
)
```

``Coordinator`` and ``AnyCoordinator`` add parent-child flow management on top of routing. They are useful when one feature should own nested flows but still expose a small surface area to the outside.

## Design Intent

These utility types are intentionally narrow. They are good adapter boundaries:

- loggers hide the logging backend
- caches hide storage policy
- mappers keep transformation logic explicit
- validators keep rules composable
- routers keep navigation outside feature logic

That makes the package useful both as a lightweight toolbox and as glue around larger application frameworks.
