import Foundation

/// A protocol for logging messages.
///
/// Loggers abstract over different logging implementations (OSLog, print,
/// third-party frameworks) for flexible logging configuration.
///
/// ## Example
/// ```swift
/// struct ConsoleLogger: Logger {
///     func log(_ message: String, level: LogLevel) {
///         print("[\(level)] \(message)")
///     }
/// }
/// ```
public protocol Logger {
    /// Logs a message with the specified level.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - level: The severity level of the log.
    ///   - file: The source file (auto-populated).
    ///   - function: The function name (auto-populated).
    ///   - line: The line number (auto-populated).
    func log(
        _ message: String,
        level: LogLevel,
        file: String,
        function: String,
        line: Int
    )
}

/// The severity level of a log message.
public enum LogLevel: Int, Comparable, Sendable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case critical = 4

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// The string representation of the log level.
    public var name: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARN"
        case .error: return "ERROR"
        case .critical: return "CRITICAL"
        }
    }
}
