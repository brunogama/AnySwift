/// A protocol for navigation routing.
///
/// Routers abstract navigation logic from view controllers, enabling
/// testable and reusable navigation flows.
///
/// ## Example
/// ```swift
/// protocol AppRouter: Router {
///     func showUserProfile(userId: String)
///     func showSettings()
/// }
/// ```
public protocol Router {
    /// Navigates to a specific route.
    ///
    /// - Parameter route: The route to navigate to.
    func navigate(to route: String)

    /// Presents a route modally.
    ///
    /// - Parameter route: The route to present.
    func present(_ route: String)

    /// Dismisses the current modal presentation.
    func dismiss()

    /// Navigates back to the previous screen.
    func goBack()

    /// Navigates to the root of the navigation stack.
    func goToRoot()
}
