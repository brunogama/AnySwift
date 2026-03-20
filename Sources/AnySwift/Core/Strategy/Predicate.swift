/// A type that defines a predicate for testing values.
///
/// The `Predicate` protocol is useful for encapsulating validation logic
/// that can be varied at runtime.
///
/// ## Example
/// ```swift
/// struct IsEvenPredicate: Predicate {
///     func test(_ value: Int) -> Bool {
///         value % 2 == 0
///     }
/// }
/// ```
public protocol Predicate<Element> {
    associatedtype Element

    /// Tests whether the given element satisfies the predicate.
    ///
    /// - Parameter element: The element to test.
    /// - Returns: `true` if the element satisfies the predicate, `false` otherwise.
    func test(_ element: Element) -> Bool
}
