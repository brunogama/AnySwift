# ``AnySwift``

Type erasure utilities for Swift protocols and generic types.

## Overview

AnySwift provides a collection of type-erased wrappers for common Swift patterns, enabling you to store and use heterogeneous implementations without exposing their concrete types. This is essential for building modular, testable, and composable Swift applications.

### Why Type Erasure?

Swift's type system is powerful but strict. Protocols with associated types or `Self` requirements cannot be used as types directly. Type erasure bridges this gap by wrapping concrete implementations behind a common interface.

```swift
// Without type erasure - this won't compile
var strategies: [Strategy] = [] // Error: Protocol 'Strategy' can only be used as a generic constraint

// With AnySwift
var strategies: [AnyStrategy<Input, Output>] = [
    AnyStrategy(concreteStrategyA),
    AnyStrategy(concreteStrategyB)
]
```

## Start Here

- <doc:Getting-Started>

## Topics

### Guides

- <doc:Getting-Started>
- <doc:Callable>
- <doc:Strategy>
- <doc:Factory>
- <doc:Middleware>
- <doc:Architecture>
- <doc:Commands-and-Queries>
- <doc:State-and-Observation>
- <doc:Support-Utilities>
- <doc:Cancellation>
- <doc:AsyncSequences>

### Callable Types

Type-erased wrappers for functions and closures.

- ``AnyFunction``
- ``AnyThrowingFunction``
- ``AnyAsyncFunction``
- ``AnyAsyncThrowingFunction``
- ``Callable``
- ``ThrowingCallable``
- ``AsyncCallable``
- ``AsyncThrowingCallable``

### Strategy Pattern

Encapsulate algorithms and make them interchangeable.

- ``AnyStrategy``
- ``Strategy``
- ``AnyPredicate``
- ``Predicate``

### Factory Pattern

Create objects without specifying the exact class.

- ``AnyFactory``
- ``Factory``
- ``AnyAsyncFactory``
- ``AsyncFactory``

### Middleware Pattern

Composable processing pipelines for transforming values.

- ``AnyMiddleware``
- ``Middleware``
- ``AnyAsyncMiddleware``
- ``AsyncMiddleware``

### Architecture And Flows

App-facing abstractions for repositories, use cases, queries, commands, and presenters.

- <doc:Architecture>
- <doc:Commands-and-Queries>

- ``AnyRepository``
- ``AnyDataSource``
- ``AnyLocalDataSource``
- ``AnyRemoteDataSource``
- ``AnyUseCase``
- ``AnyParameterlessUseCase``
- ``AnyQuery``
- ``AnyParameterizedQuery``
- ``QueryBus``
- ``AnyCommand``
- ``AnyResultCommand``
- ``CommandQueue``
- ``AnyPresenter``

### State And Coordination

Wrappers for state flow, observation, navigation, and coordination.

- <doc:State-and-Observation>

- ``AnyStore``
- ``AnyObserver``
- ``AnyPublisher``
- ``AnyRouter``
- ``AnyCoordinator``

### Utilities

Cross-cutting wrappers for logging, storage, mapping, and validation.

- <doc:Support-Utilities>

- ``AnyLogger``
- ``AnyCache``
- ``AnyMapper``
- ``AnyValidator``

### Cancellation

Abstract cancellation mechanisms for async operations.

- ``AnyCancellation``
- ``Cancellation``

### Async Sequences

Type-erased wrappers for async sequences.

- ``AnyAsyncSequence``
- ``AnyAsyncIterator``

## Installation

Add AnySwift to your `Package.swift`:

```swift
dependencies: [
    .package(path: "../AnySwift")
]
```

If you publish the package, replace the local path with your remote URL.

## Platform Support

- iOS 13.0+
- macOS 10.15+
- tvOS 13.0+
- watchOS 6.0+
- macCatalyst 13.0+
