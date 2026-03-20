/// A protocol for presenters in MVP architecture.
///
/// Presenters handle presentation logic and mediate between the view and domain layers.
///
/// ## Example
/// ```swift
/// protocol UserPresenter: Presenter {
///     func loadUser(id: String)
///     func displayUser(_ user: User)
/// }
/// ```
public protocol Presenter {
    /// Called when the view is ready.
    func viewDidLoad()

    /// Called when the view is about to appear.
    func viewWillAppear()

    /// Called when the view has appeared.
    func viewDidAppear()

    /// Called when the view is about to disappear.
    func viewWillDisappear()
}

extension Presenter {
    public func viewDidLoad() {}
    public func viewWillAppear() {}
    public func viewDidAppear() {}
    public func viewWillDisappear() {}
}
