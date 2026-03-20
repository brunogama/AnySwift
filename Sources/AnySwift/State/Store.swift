/// A protocol for state management stores.
///
/// Stores manage application state and notify observers of changes.
/// This pattern is common in Redux, MVVM, and similar architectures.
///
/// ## Example
/// ```swift
/// struct AppState {
///     var user: User?
///     var isLoading: Bool
/// }
///
/// enum AppAction {
///     case setUser(User?)
///     case setLoading(Bool)
/// }
///
/// class AppStore: Store {
///     typealias State = AppState
///     typealias Action = AppAction
///
///     func reduce(_ state: AppState, with action: AppAction) -> AppState {
///         var newState = state
///         switch action {
///         case .setUser(let user):
///             newState.user = user
///         case .setLoading(let loading):
///             newState.isLoading = loading
///         }
///         return newState
///     }
/// }
/// ```
public protocol Store<State, Action>: Observer {
    associatedtype State
    associatedtype Action

    /// The current state of the store.
    var state: State { get }

    /// Dispatches an action to update the state.
    ///
    /// - Parameter action: The action to dispatch.
    func dispatch(_ action: Action)

    /// Reduces the current state with an action to produce a new state.
    ///
    /// - Parameters:
    ///   - state: The current state.
    ///   - action: The action to apply.
    /// - Returns: The new state.
    func reduce(_ state: State, with action: Action) -> State
}
