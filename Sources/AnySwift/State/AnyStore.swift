/// A type-erased store wrapper.
///
/// Use `AnyStore` to work with different store implementations polymorphically.
public struct AnyStore<State, Action>: Store {
    @usableFromInline
    let stateBox: () -> State
    @usableFromInline
    let dispatchBox: (Action) -> Void
    @usableFromInline
    let reduceBox: (State, Action) -> State
    @usableFromInline
    let onNextBox: (Action) -> Void
    @usableFromInline
    let onErrorBox: (Error) -> Void
    @usableFromInline
    let onCompleteBox: () -> Void

    public var state: State {
        stateBox()
    }

    @inlinable
    public init<S: Store>(_ store: S) where S.State == State, S.Action == Action {
        self.stateBox = { store.state }
        self.dispatchBox = store.dispatch
        self.reduceBox = store.reduce
        self.onNextBox = { _ in }
        self.onErrorBox = { _ in }
        self.onCompleteBox = {}
    }

    @inlinable
    public init(
        state: @escaping () -> State,
        dispatch: @escaping (Action) -> Void,
        reduce: @escaping (State, Action) -> State
    ) {
        self.stateBox = state
        self.dispatchBox = dispatch
        self.reduceBox = reduce
        self.onNextBox = { _ in }
        self.onErrorBox = { _ in }
        self.onCompleteBox = {}
    }

    @inlinable
    public func dispatch(_ action: Action) {
        dispatchBox(action)
    }

    @inlinable
    public func reduce(_ state: State, with action: Action) -> State {
        reduceBox(state, action)
    }

    @inlinable
    public func onNext(_ value: Action) {
        onNextBox(value)
    }

    @inlinable
    public func onError(_ error: Error) {
        onErrorBox(error)
    }

    @inlinable
    public func onComplete() {
        onCompleteBox()
    }
}

/// A simple in-memory store implementation.
public final class InMemoryStore<State, Action>: Store {
    private var _state: State
    private let reducer: (State, Action) -> State
    private var subscribers: [(State) -> Void] = []

    public var state: State { _state }

    public init(initialState: State, reducer: @escaping (State, Action) -> State) {
        self._state = initialState
        self.reducer = reducer
    }

    public func dispatch(_ action: Action) {
        _state = reducer(_state, action)
        subscribers.forEach { $0(_state) }
    }

    public func reduce(_ state: State, with action: Action) -> State {
        reducer(state, action)
    }

    /// Subscribes to state changes.
    public func subscribe(_ handler: @escaping (State) -> Void) {
        subscribers.append(handler)
    }

    public func onNext(_ value: Action) {}
    public func onError(_ error: Error) {}
    public func onComplete() {}
}

/// A store that can be observed for state changes.
public final class ObservableStore<State, Action>: Store {
    @usableFromInline
    var _state: State
    @usableFromInline
    let reducer: (State, Action) -> State
    @usableFromInline
    let subject: PassthroughSubject<State>

    public var state: State { _state }

    public init(initialState: State, reducer: @escaping (State, Action) -> State) {
        self._state = initialState
        self.reducer = reducer
        self.subject = PassthroughSubject()
    }

    @inlinable
    public func dispatch(_ action: Action) {
        _state = reducer(_state, action)
        subject.send(_state)
    }

    @inlinable
    public func reduce(_ state: State, with action: Action) -> State {
        reducer(state, action)
    }

    /// Subscribes an observer to state changes.
    @inlinable
    public func subscribe(_ observer: AnyObserver<State>) {
        subject.subscribe(observer)
    }

    public func onNext(_ value: Action) {}
    public func onError(_ error: Error) {}
    public func onComplete() {}
}
