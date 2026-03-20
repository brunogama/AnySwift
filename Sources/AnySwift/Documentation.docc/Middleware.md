# Middleware Pattern

Composable processing pipelines for transforming values.

## Overview

Middleware provides a way to compose processing steps that transform values. Each middleware can modify, observe, or pass through the value.

## Types

### ``AnyMiddleware``

A type-erased middleware for synchronous processing.

```swift
struct RequestProcessor {
    var middlewares: [AnyMiddleware<Request>] = []

    func process(_ request: Request) -> Request {
        middlewares.reduce(request) { request, middleware in
            middleware.process(request)
        }
    }
}

var processor = RequestProcessor()
processor.middlewares = [
    AnyMiddleware { request in
        var mutable = request
        mutable.headers["X-Request-ID"] = UUID().uuidString
        return mutable
    },
    AnyMiddleware { request in
        var mutable = request
        mutable.headers["X-Timestamp"] = "\(Date().timeIntervalSince1970)"
        return mutable
    }
]

let processed = processor.process(request)
```

### ``AnyAsyncMiddleware``

A type-erased middleware for asynchronous processing.

```swift
struct AsyncRequestProcessor {
    var middlewares: [AnyAsyncMiddleware<Request>] = []

    func process(_ request: Request) async -> Request {
        var result = request
        for middleware in middlewares {
            result = await middleware.process(result)
        }
        return result
    }
}

var processor = AsyncRequestProcessor()
processor.middlewares = [
    AnyAsyncMiddleware { request in
        var mutable = request
        mutable.headers["X-Processed"] = "true"
        return mutable
    },
    AnyAsyncMiddleware { request in
        try? await Task.sleep(nanoseconds: 100_000)
        return request
    }
]

let processed = await processor.process(request)
```

## Composition

Middleware can be composed using the `composed(with:)` method:

```swift
let logging = AnyMiddleware<Request> { request in
    print("Processing request: \(request)")
    return request
}

let authentication = AnyMiddleware<Request> { request in
    var mutable = request
    mutable.headers["Authorization"] = getAuthToken()
    return mutable
}

// Compose into single middleware
let pipeline = logging.composed(with: authentication)
```

## Use Cases

### HTTP Request Pipeline

Build HTTP request processing pipelines:

```swift
class HTTPClient {
    var requestMiddlewares: [AnyMiddleware<URLRequest>] = []
    var responseMiddlewares: [AnyMiddleware<Data>] = []

    func send(_ request: URLRequest) async throws -> Data {
        let processedRequest = requestMiddlewares.reduce(request) { req, mw in
            mw.process(req as! URLRequest) // Cast needed for URLRequest
        }
        let (data, _) = try await URLSession.shared.data(for: processedRequest)
        return responseMiddlewares.reduce(data) { d, mw in mw.process(d) }
    }
}
```

### Event Processing

Process events through multiple handlers:

```swift
struct EventBus {
    var middlewares: [AnyMiddleware<Event>] = []

    func publish(_ event: Event) {
        let processed = middlewares.reduce(event) { e, mw in mw.process(e) }
        // Deliver processed event to subscribers
    }
}

let bus = EventBus()
bus.middlewares = [
    AnyMiddleware { event in
        var e = event
        e.timestamp = Date()
        return e
    },
    AnyMiddleware { event in
        print("Event: \(event)")
        return event
    }
]
```

### Data Validation and Transformation

Chain validation and transformation steps:

```swift
struct DataPipeline<T> {
    var middlewares: [AnyMiddleware<T>] = []

    func process(_ value: T) -> T {
        middlewares.reduce(value) { v, mw in mw.process(v) }
    }
}

let stringPipeline = DataPipeline<String>(
    middlewares: [
        AnyMiddleware { $0.trimmingCharacters(in: .whitespaces) },
        AnyMiddleware { $0.lowercased() },
        AnyMiddleware { $0.replacingOccurrences(of: "  ", with: " ") }
    ]
)

let cleaned = stringPipeline.process("  HELLO  WORLD  ") // "hello world"
```
