# Async Sequences

Type-erased wrappers for async sequences.

## Overview

Async sequences are a powerful Swift feature for handling streams of async values. However, their generic nature makes them difficult to store or return from functions with different concrete types.

## Types

### ``AnyAsyncSequence``

A type-erased async sequence.

```swift
protocol DataProvider {
    func fetchItems() -> AnyAsyncSequence<Item>
}

struct NetworkDataProvider: DataProvider {
    func fetchItems() -> AnyAsyncSequence<Item> {
        AnyAsyncSequence(
            URLSession.shared.data(from: url)
                .map { data, _ in try JSONDecoder().decode([Item].self, from: data) }
                .flatMap { $0.async }
        )
    }
}

struct MockDataProvider: DataProvider {
    func fetchItems() -> AnyAsyncSequence<Item> {
        AnyAsyncSequence([Item.mock1, Item.mock2].async)
    }
}

// Usage
let provider: DataProvider = isTesting ? MockDataProvider() : NetworkDataProvider()
for await item in provider.fetchItems() {
    print(item)
}
```

### ``AnyAsyncIterator``

A type-erased async iterator.

```swift
func createIterator() -> AnyAsyncIterator<Int> {
    if useMockData {
        var values = [1, 2, 3].makeIterator()
        return AnyAsyncIterator {
            values.next()
        }
    } else {
        return AnyAsyncIterator(asyncSequence.makeAsyncIterator())
    }
}

var iterator = createIterator()
while let value = await iterator.next() {
    print(value)
}
```

## Extensions

### ``AsyncSequence/eraseToAnyAsyncSequence()``

Erases an async sequence to `AnyAsyncSequence`.

```swift
let sequence = [1, 2, 3].async
    .map { $0 * 2 }
    .filter { $0 > 2 }
    .eraseToAnyAsyncSequence()

// sequence is now AnyAsyncSequence<Int>
for await value in sequence {
    print(value)
}
```

## Use Cases

### Abstracting Data Sources

Return different sequence types from a single interface:

```swift
protocol FeedProvider {
    func posts() -> AnyAsyncSequence<Post>
}

struct LocalFeedProvider: FeedProvider {
    func posts() -> AnyAsyncSequence<Post> {
        AnyAsyncSequence(
            localDatabase.posts()
                .async
                .map { $0.toDomain() }
        )
    }
}

struct RemoteFeedProvider: FeedProvider {
    func posts() -> AnyAsyncSequence<Post> {
        AnyAsyncSequence(
            apiClient.fetchPosts()
                .flatMap { $0.async }
        )
    }
}
```

### Transforming Sequences

Apply transformations while maintaining type erasure:

```swift
func filteredItems(matching query: String) -> AnyAsyncSequence<Item> {
    allItems()
        .filter { $0.name.contains(query) }
        .eraseToAnyAsyncSequence()
}

// Usage
for await item in filteredItems(matching: "swift") {
    display(item)
}
```

### Testing

Mock async sequences for testing:

```swift
class ItemRepositoryTests: XCTestCase {
    func testFetchItems() async {
        let mockItems: [Item] = [.mock1, .mock2]
        let repository = MockRepository(
            items: AnyAsyncSequence(mockItems.async)
        )

        var received: [Item] = []
        for await item in repository.fetchItems() {
            received.append(item)
        }

        XCTAssertEqual(received, mockItems)
    }
}
```
