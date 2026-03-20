import Testing

@testable import AnySwift

@Suite("Coordinator Tests")
struct CoordinatorTests {
  @Test("any coordinator reflects child coordinator mutations")
  func anyCoordinatorReflectsChildCoordinatorMutations() {
    let base = TestCoordinator()
    let child = AnyCoordinator(TestCoordinator())
    var coordinator = AnyCoordinator(base)

    #expect(coordinator.childCoordinators.isEmpty)

    coordinator.addChild(child)
    #expect(coordinator.childCoordinators.count == 1)
    #expect(base.childCoordinators.count == 1)

    coordinator.childCoordinators = []
    #expect(coordinator.childCoordinators.isEmpty)
    #expect(base.childCoordinators.isEmpty)
  }
}

private final class TestCoordinator: Coordinator {
  var childCoordinators: [AnyCoordinator] = []

  func navigate(to route: String) {}
  func present(_ route: String) {}
  func dismiss() {}
  func goBack() {}
  func goToRoot() {}
  func start() {}

  func addChild(_ coordinator: AnyCoordinator) {
    childCoordinators.append(coordinator)
  }

  func removeChild(_ coordinator: AnyCoordinator) {
    childCoordinators.removeAll()
  }
}
