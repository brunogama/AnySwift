# Cancellation

Type-erased cancellation for async operations.

## Overview

The `AnyCancellation` type provides a unified interface for cancelling various async operations, including `Task`, `DispatchWorkItem`, and `URLSessionTask`.

## Types

### ``AnyCancellation``

A type-erased cancellation wrapper.

```swift
class OperationManager {
    var cancellables: [String: AnyCancellation] = [:]

    func register(_ id: String, cancellation: AnyCancellation) {
        cancellables[id] = cancellation
    }

    func cancel(_ id: String) {
        cancellables[id]?.cancel()
        cancellables.removeValue(forKey: id)
    }
}

// Usage
let manager = OperationManager()

// With Task
let task = Task {
    await fetchData()
}
manager.register("fetch", cancellation: AnyCancellation(task))

// Later
manager.cancel("fetch")
```

## Convenience Initializers

### From Task

```swift
let asyncTask = Task {
    await longRunningOperation()
}
let cancellation = AnyCancellation(asyncTask)
```

### From DispatchWorkItem

```swift
let workItem = DispatchWorkItem {
    performWork()
}
DispatchQueue.global().async(execute: workItem)

let cancellation = AnyCancellation(workItem)
```

### From URLSessionTask

```swift
let dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
    // Handle response
}
dataTask.resume()

let cancellation = AnyCancellation(dataTask)
```

### From Closures

```swift
let customCancellation = AnyCancellation(
    cancel: {
        // Custom cancellation logic
        isCancelled = true
    },
    isCancelled: {
        isCancelled
    }
)
```

## Use Cases

### Request Management

Manage multiple in-flight requests:

```swift
class APIClient {
    private var activeTasks: [String: AnyCancellation] = [:]

    func fetch(_ id: String, request: URLRequest) async throws -> Data {
        // Cancel any existing request with same ID
        activeTasks[id]?.cancel()

        let task = Task {
            try await URLSession.shared.data(for: request).0
        }

        activeTasks[id] = AnyCancellation(task)

        defer { activeTasks.removeValue(forKey: id) }
        return try await task.value
    }

    func cancel(_ id: String) {
        activeTasks[id]?.cancel()
        activeTasks.removeValue(forKey: id)
    }
}
```

### Cooperative Cancellation

Implement cooperative cancellation in async work:

```swift
struct CancellableWork {
    let cancellation: AnyCancellation

    func perform() async {
        while !cancellation.isCancelled {
            // Do work
            await doIncrementalWork()

            // Check cancellation periodically
            if cancellation.isCancelled {
                break
            }
        }
    }
}

let task = Task {
    await CancellableWork(cancellation: AnyCancellation(Task.current!))
        .perform()
}
```

### Resource Cleanup

Ensure resources are properly cleaned up on cancellation:

```swift
func loadResource() async throws -> Resource {
    let resource = try await acquireResource()

    // Register cleanup on cancellation
    let cancellation = AnyCancellation(
        cancel: {
            Task {
                await resource.release()
            }
        }
    )

    do {
        let result = try await process(resource)
        return result
    } catch {
        cancellation.cancel()
        throw error
    }
}
```
