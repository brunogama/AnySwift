/// A type-erased presenter wrapper.
///
/// Use `AnyPresenter` to work with different presenter implementations polymorphically.
public struct AnyPresenter: Presenter {
    @usableFromInline
    let viewDidLoadBox: () -> Void
    @usableFromInline
    let viewWillAppearBox: () -> Void
    @usableFromInline
    let viewDidAppearBox: () -> Void
    @usableFromInline
    let viewWillDisappearBox: () -> Void

    @inlinable
    public init<P: Presenter>(_ presenter: P) {
        self.viewDidLoadBox = presenter.viewDidLoad
        self.viewWillAppearBox = presenter.viewWillAppear
        self.viewDidAppearBox = presenter.viewDidAppear
        self.viewWillDisappearBox = presenter.viewWillDisappear
    }

    @inlinable
    public init(
        viewDidLoad: @escaping () -> Void = {},
        viewWillAppear: @escaping () -> Void = {},
        viewDidAppear: @escaping () -> Void = {},
        viewWillDisappear: @escaping () -> Void = {}
    ) {
        self.viewDidLoadBox = viewDidLoad
        self.viewWillAppearBox = viewWillAppear
        self.viewDidAppearBox = viewDidAppear
        self.viewWillDisappearBox = viewWillDisappear
    }

    @inlinable
    public func viewDidLoad() {
        viewDidLoadBox()
    }

    @inlinable
    public func viewWillAppear() {
        viewWillAppearBox()
    }

    @inlinable
    public func viewDidAppear() {
        viewDidAppearBox()
    }

    @inlinable
    public func viewWillDisappear() {
        viewWillDisappearBox()
    }
}
