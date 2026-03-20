/// A type-erased async iterator.
///
/// Use `AnyAsyncIterator` when you need to store async iterators with different
/// implementations without exposing their concrete types.
///
/// ## Example
/// ```swift
/// func createIterator() -> AnyAsyncIterator<Int> {
///     if useMockData {
///         var values = [1, 2, 3].makeIterator()
///         return AnyAsyncIterator {
///             values.next()
///         }
///     } else {
///         return AnyAsyncIterator(asyncSequence.iterator())
///     }
/// }
///
/// var iterator = createIterator()
/// while let value = await iterator.next() {
///     print(value)
/// }
/// ```
public struct AnyAsyncIterator<Element>: AsyncIteratorProtocol {
    @usableFromInline
    let box: () async -> Element?

    /// Creates a type-erased async iterator from a concrete async iterator.
    ///
    /// - Parameter iterator: The async iterator to wrap.
    @inlinable
    public init<I: AsyncIteratorProtocol>(_ iterator: I) where I.Element == Element {
        var iterator = iterator
        self.box = { try? await iterator.next() }
    }

    /// Creates a type-erased async iterator from a closure.
    ///
    /// - Parameter next: The closure that returns the next element.
    @inlinable
    public init(_ next: @escaping () async -> Element?) {
        self.box = next
    }

    /// Advances to the next element and returns it, or `nil` if no next element exists.
    ///
    /// - Returns: The next element, or `nil` if the iterator is exhausted.
    @inlinable
    public mutating func next() async -> Element? {
        await box()
    }
}
