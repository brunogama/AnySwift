/// A type-erased observer wrapper.
///
/// Use `AnyObserver` to work with different observer implementations polymorphically.
public struct AnyObserver<Value>: Observer {
    @usableFromInline
    final class Storage {
        @usableFromInline let onNextBox: (Value) -> Void
        @usableFromInline let onErrorBox: (Error) -> Void
        @usableFromInline let onCompleteBox: () -> Void

    @usableFromInline
    init(
      onNext: @escaping (Value) -> Void,
      onError: @escaping (Error) -> Void,
      onComplete: @escaping () -> Void
    ) {
      self.onNextBox = onNext
      self.onErrorBox = onError
      self.onCompleteBox = onComplete
    }
  }

    @usableFromInline let storage: Storage

    @usableFromInline var identity: ObjectIdentifier {
        ObjectIdentifier(storage)
    }

  @inlinable
  public init<O: Observer>(_ observer: O) where O.Value == Value {
    self.storage = Storage(
      onNext: observer.onNext,
      onError: observer.onError,
      onComplete: observer.onComplete
    )
  }

  @inlinable
  public init(
    onNext: @escaping (Value) -> Void = { _ in },
    onError: @escaping (Error) -> Void = { _ in },
    onComplete: @escaping () -> Void = {}
  ) {
    self.storage = Storage(
      onNext: onNext,
      onError: onError,
      onComplete: onComplete
    )
  }

  @inlinable
  public func onNext(_ value: Value) {
    storage.onNextBox(value)
  }

  @inlinable
  public func onError(_ error: Error) {
    storage.onErrorBox(error)
  }

  @inlinable
  public func onComplete() {
    storage.onCompleteBox()
  }
}

/// A type-erased publisher wrapper.
public struct AnyPublisher<Value>: Publisher {
    @usableFromInline let subscribeBox: (AnyObserver<Value>) -> Void
    @usableFromInline let unsubscribeBox: (AnyObserver<Value>) -> Void

  @inlinable
  public init<P: Publisher>(_ publisher: P) where P.Value == Value {
    self.subscribeBox = { observer in
      publisher.subscribe(observer)
    }
    self.unsubscribeBox = { observer in
      publisher.unsubscribe(observer)
    }
  }

  @inlinable
  public init(
    subscribe: @escaping (AnyObserver<Value>) -> Void,
    unsubscribe: @escaping (AnyObserver<Value>) -> Void = { _ in }
  ) {
    self.subscribeBox = subscribe
    self.unsubscribeBox = unsubscribe
  }

  @inlinable
  public func subscribe(_ observer: AnyObserver<Value>) {
    subscribeBox(observer)
  }

  @inlinable
  public func unsubscribe(_ observer: AnyObserver<Value>) {
    unsubscribeBox(observer)
  }
}

/// A simple subject that can emit values to multiple observers.
public final class PassthroughSubject<Value>: Publisher {
    @usableFromInline var observers: [AnyObserver<Value>] = []

  public init() {}

  public func subscribe(_ observer: AnyObserver<Value>) {
    observers.append(observer)
  }

  public func unsubscribe(_ observer: AnyObserver<Value>) {
    observers.removeAll { existingObserver in
      existingObserver.identity == observer.identity
    }
  }

  /// Emits a value to all subscribed observers.
  public func send(_ value: Value) {
    observers.forEach { $0.onNext(value) }
  }

  /// Emits an error to all subscribed observers.
  public func send(error: Error) {
    observers.forEach { $0.onError(error) }
  }

  /// Signals completion to all subscribed observers.
  public func sendComplete() {
    observers.forEach { $0.onComplete() }
  }
}
