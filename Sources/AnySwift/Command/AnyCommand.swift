/// A type-erased command wrapper.
///
/// Use `AnyCommand` to work with different command implementations polymorphically.
///
/// ## Example
/// ```swift
/// class CommandInvoker {
///     private var history: [AnyCommand] = []
///
///     func execute(_ command: AnyCommand) async throws {
///         try await command.execute()
///         history.append(command)
///     }
///
///     func undoLast() async throws {
///         guard let last = history.popLast() else { return }
///         try await last.undo()
///     }
/// }
/// ```
public struct AnyCommand: Command {
    @usableFromInline
    let executeBox: () async throws -> Void
    @usableFromInline
    let undoBox: () async throws -> Void
    @usableFromInline
    let canExecuteBox: () -> Bool

    @inlinable
    public init<C: Command>(_ command: C) {
        self.executeBox = command.execute
        self.undoBox = command.undo
        self.canExecuteBox = { command.canExecute }
    }

    @inlinable
    public init(
        execute: @escaping () async throws -> Void,
        undo: @escaping () async throws -> Void = {},
        canExecute: @escaping () -> Bool = { true }
    ) {
        self.executeBox = execute
        self.undoBox = undo
        self.canExecuteBox = canExecute
    }

    @inlinable
    public func execute() async throws {
        try await executeBox()
    }

    @inlinable
    public func undo() async throws {
        try await undoBox()
    }

    @inlinable
    public var canExecute: Bool {
        canExecuteBox()
    }
}

/// A type-erased result command wrapper.
public struct AnyResultCommand<Result>: ResultCommand {
    @usableFromInline
    let executeBox: () async throws -> Result
    @usableFromInline
    let undoBox: () async throws -> Void
    @usableFromInline
    let canExecuteBox: () -> Bool

    @inlinable
    public init<C: ResultCommand>(_ command: C) where C.Result == Result {
        self.executeBox = command.execute
        self.undoBox = command.undo
        self.canExecuteBox = { command.canExecute }
    }

    @inlinable
    public init(
        execute: @escaping () async throws -> Result,
        undo: @escaping () async throws -> Void = {},
        canExecute: @escaping () -> Bool = { true }
    ) {
        self.executeBox = execute
        self.undoBox = undo
        self.canExecuteBox = canExecute
    }

    @inlinable
    public func execute() async throws -> Result {
        try await executeBox()
    }

    @inlinable
    public func undo() async throws {
        try await undoBox()
    }

    @inlinable
    public var canExecute: Bool {
        canExecuteBox()
    }
}

/// A command queue that manages command execution and history.
public final class CommandQueue {
    private var history: [AnyCommand] = []
    private var redoStack: [AnyCommand] = []

    /// Executes a command and adds it to history.
    public func execute(_ command: AnyCommand) async throws {
        guard command.canExecute else { return }
        try await command.execute()
        history.append(command)
        redoStack.removeAll()
    }

    /// Undoes the last executed command.
    @discardableResult
    public func undo() async throws -> Bool {
        guard let last = history.popLast() else { return false }
        try await last.undo()
        redoStack.append(last)
        return true
    }

    /// Redoes the last undone command.
    @discardableResult
    public func redo() async throws -> Bool {
        guard let last = redoStack.popLast() else { return false }
        try await last.execute()
        history.append(last)
        return true
    }

    /// Clears all command history.
    public func clear() {
        history.removeAll()
        redoStack.removeAll()
    }

    /// Returns whether an undo operation is available.
    public var canUndo: Bool {
        !history.isEmpty
    }

    /// Returns whether a redo operation is available.
    public var canRedo: Bool {
        !redoStack.isEmpty
    }
}
