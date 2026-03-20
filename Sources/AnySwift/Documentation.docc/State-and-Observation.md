# State and Observation

Use these types when you want a lightweight store, publisher, or observer pipeline without pulling in a larger reactive framework.

## Overview

AnySwift includes two related families:

- observation primitives like ``Observer``, ``AnyObserver``, ``Publisher``, and ``PassthroughSubject``
- store primitives like ``Store``, ``AnyStore``, ``InMemoryStore``, and ``ObservableStore``

Together they cover simple Redux-like flows and basic event broadcasting.

## Observers and Publishers

### ``AnyObserver``

Use a type-erased observer when you want to capture callbacks inline or store heterogeneous observers together.

```swift
let observer = AnyObserver<Int>(
    onNext: { print("value:", $0) },
    onError: { print("error:", $0) },
    onComplete: { print("done") }
)
```

### ``AnyPublisher`` and ``PassthroughSubject``

``PassthroughSubject`` is the concrete publisher in the package. ``AnyPublisher`` is useful when you want to pass the publisher around without exposing the concrete type.

```swift
let subject = PassthroughSubject<String>()
let publisher = AnyPublisher(subject)

publisher.subscribe(
    AnyObserver(onNext: { print("message:", $0) })
)

subject.send("hello")
```

## Stores

### ``Store``

A store exposes current state, accepts actions through `dispatch(_:)`, and knows how to reduce a state and action pair.

### ``InMemoryStore``

Use this when a closure-based reducer is enough.

```swift
struct CounterState {
    var count: Int
}

enum CounterAction {
    case increment
    case decrement
}

let store = InMemoryStore<CounterState, CounterAction>(
    initialState: CounterState(count: 0)
) { state, action in
    var next = state
    switch action {
    case .increment:
        next.count += 1
    case .decrement:
        next.count -= 1
    }
    return next
}

store.subscribe { state in
    print("count:", state.count)
}
```

### ``ObservableStore``

Use this when you want store updates to flow through ``AnyObserver`` values.

```swift
let store = ObservableStore<CounterState, CounterAction>(
    initialState: CounterState(count: 0)
) { state, action in
    var next = state
    if case .increment = action {
        next.count += 1
    }
    return next
}

store.subscribe(
    AnyObserver(onNext: { state in
        print("observed count:", state.count)
    })
)
```

### ``AnyStore``

Use the type-erased wrapper when your feature should accept any store implementation that matches the same `State` and `Action`.

```swift
struct CounterViewModel {
    let store: AnyStore<CounterState, CounterAction>

    func increment() {
        store.dispatch(.increment)
    }
}
```

## Practical Fit

These types are intentionally small. They are a good fit when you want:

- a simple reducer loop
- dependency injection around state handling
- test-friendly observation without a full framework dependency

If you need advanced operators, scheduling, or backpressure, use these as boundary types and integrate a richer reactive system behind them.
