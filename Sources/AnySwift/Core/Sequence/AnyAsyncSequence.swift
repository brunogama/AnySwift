/// A type-erased async sequence.
///
/// Use `AnyAsyncSequence` when you need to return or store async sequences
/// without exposing their concrete types. This is particularly useful in
/// protocol requirements or when returning different sequence types conditionally.
///
/// ## Example
/// ```swift
/// protocol DataProvider {
///     func fetchItems() -> AnyAsyncSequence<Item>
/// }
///
/// struct NetworkDataProvider: DataProvider {
///     func fetchItems() -> AnyAsyncSequence<Item> {
///         AnyAsyncSequence(
///             URLSession.shared.data(from: url)
///                 .map { data, _ in try JSONDecoder().decode([Item].self, from: data) }
///                 .flatMap { $0.async }
///         )
///     }
/// }
///
/// struct MockDataProvider: DataProvider {///     func fetchItems() -> AnyAsyncSequence<Item> {
///         AnyAsyncSequence([Item.mock1, Item.mock2].async)
///     }
/// }
///
/// for await item in dataProvider.fetchItems() {
///     print(item)
/// }
/// ```
public struct AnyAsyncSequence<Element>: AsyncSequence {
    @usableFromInline
    let makeIteratorBox: () -> AnyAsyncIterator<Element>

    /// Creates a type-erased async sequence from a concrete async sequence.
    ///
    /// - Parameter sequence: The async sequence to wrap.
    @inlinable
    public init<S: AsyncSequence>(_ sequence: S) where S.Element == Element {
        self.makeIteratorBox = { AnyAsyncIterator(sequence.makeAsyncIterator()) }
    }

    /// Creates a type-erased async sequence from an iterator factory.
    ///
    /// - Parameter makeIterator: A closure that creates the async iterator.
    @inlinable
    public init(_ makeIterator: @escaping () -> AnyAsyncIterator<Element>) {
        self.makeIteratorBox = makeIterator
    }

    /// Creates the async iterator for this sequence.
    ///
    /// - Returns: An async iterator for the sequence.
    @inlinable
    public func makeAsyncIterator() -> AnyAsyncIterator<Element> {
        makeIteratorBox()
    }
}

// MARK: - Sequence Extensions

extension AsyncSequence {
    /// Erases the async sequence to `AnyAsyncSequence`.
    ///
    /// - Returns: A type-erased async sequence.
    @inlinable
    public func eraseToAnyAsyncSequence() -> AnyAsyncSequence<Element> {
        AnyAsyncSequence(self)
    }
}
