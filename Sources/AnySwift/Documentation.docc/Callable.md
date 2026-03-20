# Callable Types

Type-erased wrappers for functions and closures of various flavors.

## Overview

The Callable types in AnySwift provide type-erased wrappers for functions, enabling you to store and use functions with different signatures in properties, collections, and protocol requirements.

## Types

### ``AnyFunction``

A type-erased wrapper for synchronous functions.

```swift
var operations: [AnyFunction<Int, Int>] = [
    AnyFunction { $0 * 2 },
    AnyFunction { $0 + 10 }
]

let results = operations.map { $0(5) } // [10, 15]
```

### ``AnyThrowingFunction``

A type-erased wrapper for throwing functions.

```swift
let validator = AnyThrowingFunction<String, String> { input in
    guard !input.isEmpty else {
        throw ValidationError.empty
    }
    return input
}

do {
    let result = try validator("hello")
} catch {
    print("Validation failed")
}
```

### ``AnyAsyncFunction``

A type-erased wrapper for async functions.

```swift
struct DataLoader {
    var fetch: AnyAsyncFunction<URL, Data>
}

let loader = DataLoader(
    fetch: AnyAsyncFunction { url in
        try await URLSession.shared.data(from: url).0
    }
)

let data = await loader.fetch(url)
```

### ``AnyAsyncThrowingFunction``

A type-erased wrapper for async throwing functions.

```swift
struct APIClient {
    var request: AnyAsyncThrowingFunction<Request, Response>
}

let client = APIClient(
    request: AnyAsyncThrowingFunction { request in
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Response.self, from: data)
    }
)

let response = try await client.request(myRequest)
```

## Use Cases

### Dependency Injection

Use callable types to inject different behaviors at runtime:

```swift
struct Calculator {
    var operation: AnyFunction<Int, Int>

    func calculate(_ input: Int) -> Int {
        operation(input)
    }
}

// Production
let doubleCalc = Calculator(operation: AnyFunction { $0 * 2 })

// Testing
let mockCalc = Calculator(operation: AnyFunction { $0 })
```

### Strategy Pattern

Store multiple algorithms and select at runtime:

```swift
class ImageProcessor {
    var filters: [AnyFunction<UIImage, UIImage>] = []

    func apply(to image: UIImage) -> UIImage {
        filters.reduce(image) { img, filter in
            filter(img)
        }
    }
}
```

### Callback Storage

Store callbacks with different implementations:

```swift
class EventHandler {
    var handlers: [AnyFunction<Event, Void>] = []

    func onEvent(_ event: Event) {
        handlers.forEach { $0(event) }
    }
}
```
