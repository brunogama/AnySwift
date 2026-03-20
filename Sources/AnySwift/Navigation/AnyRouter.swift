/// A type-erased router wrapper.
///
/// Use `AnyRouter` to abstract navigation logic.
///
/// ## Example
/// ```swift
/// class ProfileViewModel {
///     var router: AnyRouter
///
///     func showSettings() {
///         router.navigate(to: "settings")
///     }
/// }
/// ```
public struct AnyRouter: Router {
    @usableFromInline let navigateBox: (String) -> Void
    @usableFromInline let presentBox: (String) -> Void
    @usableFromInline let dismissBox: () -> Void
    @usableFromInline let goBackBox: () -> Void
    @usableFromInline let goToRootBox: () -> Void

  @inlinable
  public init<R: Router>(_ router: R) {
    self.navigateBox = router.navigate
    self.presentBox = router.present
    self.dismissBox = router.dismiss
    self.goBackBox = router.goBack
    self.goToRootBox = router.goToRoot
  }

  @inlinable
  public init(
    navigate: @escaping (String) -> Void,
    present: @escaping (String) -> Void,
    dismiss: @escaping () -> Void,
    goBack: @escaping () -> Void,
    goToRoot: @escaping () -> Void
  ) {
    self.navigateBox = navigate
    self.presentBox = present
    self.dismissBox = dismiss
    self.goBackBox = goBack
    self.goToRootBox = goToRoot
  }

  @inlinable
  public func navigate(to route: String) {
    navigateBox(route)
  }

  @inlinable
  public func present(_ route: String) {
    presentBox(route)
  }

  @inlinable
  public func dismiss() {
    dismissBox()
  }

  @inlinable
  public func goBack() {
    goBackBox()
  }

  @inlinable
  public func goToRoot() {
    goToRootBox()
  }
}

/// A coordinator that can manage child coordinators.
public protocol Coordinator: Router {
  var childCoordinators: [AnyCoordinator] { get set }

  /// Adds a child coordinator.
  func addChild(_ coordinator: AnyCoordinator)

  /// Removes a child coordinator.
  func removeChild(_ coordinator: AnyCoordinator)

  /// Starts the coordinator's flow.
  func start()
}

/// A type-erased coordinator wrapper.
public struct AnyCoordinator: Coordinator {
    @usableFromInline let navigateBox: (String) -> Void
    @usableFromInline let presentBox: (String) -> Void
    @usableFromInline let dismissBox: () -> Void
    @usableFromInline let goBackBox: () -> Void
    @usableFromInline let goToRootBox: () -> Void
    @usableFromInline let startBox: () -> Void
    @usableFromInline let addChildBox: (Self) -> Void
    @usableFromInline let removeChildBox: (Self) -> Void
    @usableFromInline let childCoordinatorsGetBox: () -> [Self]
    @usableFromInline let childCoordinatorsSetBox: ([Self]) -> Void

  public var childCoordinators: [Self] {
    get { childCoordinatorsGetBox() }
    set { childCoordinatorsSetBox(newValue) }
  }

  @inlinable
  public init<C: Coordinator>(_ coordinator: C) {
    var coordinator = coordinator
    self.navigateBox = { route in
      coordinator.navigate(to: route)
    }
    self.presentBox = { route in
      coordinator.present(route)
    }
    self.dismissBox = {
      coordinator.dismiss()
    }
    self.goBackBox = {
      coordinator.goBack()
    }
    self.goToRootBox = {
      coordinator.goToRoot()
    }
    self.startBox = {
      coordinator.start()
    }
    self.addChildBox = { child in
      coordinator.addChild(child)
    }
    self.removeChildBox = { child in
      coordinator.removeChild(child)
    }
    self.childCoordinatorsGetBox = {
      coordinator.childCoordinators
    }
    self.childCoordinatorsSetBox = { childCoordinators in
      coordinator.childCoordinators = childCoordinators
    }
  }

  @inlinable
  public func navigate(to route: String) {
    navigateBox(route)
  }

  @inlinable
  public func present(_ route: String) {
    presentBox(route)
  }

  @inlinable
  public func dismiss() {
    dismissBox()
  }

  @inlinable
  public func goBack() {
    goBackBox()
  }

  @inlinable
  public func goToRoot() {
    goToRootBox()
  }

  @inlinable
  public func start() {
    startBox()
  }

  @inlinable
  public func addChild(_ coordinator: Self) {
    addChildBox(coordinator)
  }

  @inlinable
  public func removeChild(_ coordinator: Self) {
    removeChildBox(coordinator)
  }
}
