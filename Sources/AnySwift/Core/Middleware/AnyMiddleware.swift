/// A type-erased middleware wrapper that can store any middleware.
///
/// Use `AnyMiddleware` when you need to store middleware with different implementations
/// in a property or collection without exposing their concrete types.
///
/// ## Example
/// ```swift
/// struct RequestProcessor {
///     var middlewares: [AnyMiddleware<Request>] = []
///
///     func process(_ request: Request) -> Request {
///         middlewares.reduce(request) { request, middleware in
///             middleware.process(request)
///         }
///     }
/// }
///
/// var processor = RequestProcessor()
/// processor.middlewares = [
///     AnyMiddleware { request in
///         var mutable = request
///         mutable.headers["X-Request-ID"] = UUID().uuidString
///         return mutable
///     },
///     AnyMiddleware { request in
///         var mutable = request
///         mutable.headers["X-Timestamp"] = "\(Date().timeIntervalSince1970)"
///         return mutable
///     }
/// ]
///
/// let processed = processor.process(request)
/// ```
public struct AnyMiddleware<Input>: Middleware {
    @usableFromInline
    let box: (Input) -> Input

    /// Creates a type-erased middleware from a concrete middleware.
    ///
    /// - Parameter middleware: The middleware to wrap.
    @inlinable
    public init<M: Middleware>(_ middleware: M) where M.Input == Input {
        self.box = middleware.process
    }

    /// Creates a type-erased middleware from a closure.
    ///
    /// - Parameter closure: The closure that implements the middleware logic.
    @inlinable
    public init(_ closure: @escaping (Input) -> Input) {
        self.box = closure
    }

    /// Processes the given input value.
    ///
    /// - Parameter value: The input value to process.
    /// - Returns: The processed value.
    @inlinable
    public func process(_ value: Input) -> Input {
        box(value)
    }
}

extension AnyMiddleware {
    /// Composes this middleware with another, returning a new middleware that
    /// applies both in sequence.
    ///
    /// - Parameter other: The middleware to compose with.
    /// - Returns: A new middleware that applies `self` then `other`.
    @inlinable
    public func composed(with other: AnyMiddleware<Input>) -> AnyMiddleware<Input> {
        AnyMiddleware { value in
            other.process(self.process(value))
        }
    }
}
