import Foundation

/// A type-erased logger wrapper.
///
/// Use `AnyLogger` to work with different logging implementations polymorphically.
///
/// ## Example
/// ```swift
/// struct NetworkManager {
///     var logger: AnyLogger
///
///     func fetchData() async {
///         logger.debug("Fetching data...")
///         // Fetch implementation
///         logger.info("Data fetched successfully")
///     }
/// }
/// ```
public struct AnyLogger: Logger {
    @usableFromInline
    let logBox: (String, LogLevel, String, String, Int) -> Void

    @inlinable
    public init<L: Logger>(_ logger: L) {
        self.logBox = { message, level, file, function, line in
            logger.log(message, level: level, file: file, function: function, line: line)
        }
    }

    @inlinable
    public init(_ closure: @escaping (String, LogLevel, String, String, Int) -> Void) {
        self.logBox = closure
    }

    @inlinable
    public func log(
        _ message: String,
        level: LogLevel,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        logBox(message, level, file, function, line)
    }
}

extension AnyLogger {
    /// Logs a debug message.
    @inlinable
    public func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .debug, file: file, function: function, line: line)
    }

    /// Logs an info message.
    @inlinable
    public func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .info, file: file, function: function, line: line)
    }

    /// Logs a warning message.
    @inlinable
    public func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .warning, file: file, function: function, line: line)
    }

    /// Logs an error message.
    @inlinable
    public func error(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .error, file: file, function: function, line: line)
    }

    /// Logs a critical message.
    @inlinable
    public func critical(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .critical, file: file, function: function, line: line)
    }
}

/// A composite logger that sends logs to multiple loggers.
public struct CompositeLogger: Logger {
    private let loggers: [AnyLogger]

    public init(loggers: [AnyLogger]) {
        self.loggers = loggers
    }

    public func log(
        _ message: String,
        level: LogLevel,
        file: String,
        function: String,
        line: Int
    ) {
        loggers.forEach { $0.log(message, level: level, file: file, function: function, line: line) }
    }
}

/// A simple console logger implementation.
public struct ConsoleLogger: Logger {
    private let minLevel: LogLevel

    public init(minLevel: LogLevel = .debug) {
        self.minLevel = minLevel
    }

    public func log(
        _ message: String,
        level: LogLevel,
        file: String,
        function: String,
        line: Int
    ) {
        guard level >= minLevel else { return }
        let filename = URL(fileURLWithPath: file).lastPathComponent
        print("[\(level.name)] [\(filename):\(line)] \(function): \(message)")
    }
}
