/// A type-erased predicate wrapper that can store any predicate conforming to the `Predicate` protocol.
///
/// Use `AnyPredicate` when you need to store predicates with different implementations
/// in a property or collection without exposing their concrete types.
///
/// ## Example
/// ```swift
/// struct FilterViewModel {
///     var predicates: [AnyPredicate<Product>] = []
///
///     func matches(_ product: Product) -> Bool {
///         predicates.allSatisfy { $0.test(product) }
///     }
/// }
///
/// var filters = FilterViewModel()
/// filters.predicates = [
///     AnyPredicate { $0.price < 100 },
///     AnyPredicate { !$0.name.isEmpty },
///     AnyPredicate { $0.inStock }
/// ]
///
/// let matches = filters.matches(product)
/// ```
public struct AnyPredicate<Element>: Predicate {
    @usableFromInline
    let box: (Element) -> Bool

    /// Creates a type-erased predicate from a concrete predicate.
    ///
    /// - Parameter predicate: The predicate to wrap.
    @inlinable
    public init<P: Predicate>(_ predicate: P) where P.Element == Element {
        self.box = predicate.test
    }

    /// Creates a type-erased predicate from a closure.
    ///
    /// - Parameter closure: The closure that implements the predicate logic.
    @inlinable
    public init(_ closure: @escaping (Element) -> Bool) {
        self.box = closure
    }

    /// Tests whether the given element satisfies the predicate.
    ///
    /// - Parameter element: The element to test.
    /// - Returns: `true` if the element satisfies the predicate, `false` otherwise.
    @inlinable
    public func test(_ element: Element) -> Bool {
        box(element)
    }
}

extension AnyPredicate {
    /// Combines this predicate with another using logical AND.
    ///
    /// - Parameter other: The predicate to combine with.
    /// - Returns: A new predicate that returns `true` only if both predicates return `true`.
    @inlinable
    public func and(_ other: AnyPredicate<Element>) -> AnyPredicate<Element> {
        AnyPredicate { element in
            self.test(element) && other.test(element)
        }
    }

    /// Combines this predicate with another using logical OR.
    ///
    /// - Parameter other: The predicate to combine with.
    /// - Returns: A new predicate that returns `true` if either predicate returns `true`.
    @inlinable
    public func or(_ other: AnyPredicate<Element>) -> AnyPredicate<Element> {
        AnyPredicate { element in
            self.test(element) || other.test(element)
        }
    }

    /// Returns a new predicate that negates this predicate.
    @inlinable
    public func negated() -> AnyPredicate<Element> {
        AnyPredicate { element in
            !self.test(element)
        }
    }
}
