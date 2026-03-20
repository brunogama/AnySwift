/// A protocol for observing value changes.
///
/// Observers are used to implement the observer pattern for reactive programming
/// and event-driven architectures.
///
/// ## Example
/// ```swift
/// struct UserObserver: Observer {
///     func onNext(_ user: User) {
///         print("User updated: \(user.name)")
///     }
///
///     func onError(_ error: Error) {
///         print("Error: \(error)")
///     }
///
///     func onComplete() {
///         print("Completed")
///     }
/// }
/// ```
public protocol Observer<Value> {
    associatedtype Value

    /// Called when a new value is emitted.
    func onNext(_ value: Value)

    /// Called when an error occurs.
    func onError(_ error: Error)

    /// Called when the observation completes.
    func onComplete()
}

/// A protocol for publishing values to observers.
public protocol Publisher<Value> {
    associatedtype Value

    /// Subscribes an observer to receive values.
    ///
    /// - Parameter observer: The observer to subscribe.
    func subscribe(_ observer: AnyObserver<Value>)

    /// Unsubscribes an observer.
    ///
    /// - Parameter observer: The observer to unsubscribe.
    func unsubscribe(_ observer: AnyObserver<Value>)
}
