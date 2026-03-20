/// A type-erased async middleware wrapper.
///
/// Use `AnyAsyncMiddleware` when you need to store async middleware with different
/// implementations without exposing their concrete types.
///
/// ## Example
/// ```swift
/// struct AsyncRequestProcessor {
///     var middlewares: [AnyAsyncMiddleware<Request>] = []
///
///     func process(_ request: Request) async -> Request {
///         var result = request
///         for middleware in middlewares {
///             result = await middleware.process(result)
///         }
///         return result
///     }
/// }
///
/// var processor = AsyncRequestProcessor()
/// processor.middlewares = [
///     AnyAsyncMiddleware { request in
///         var mutable = request
///         mutable.headers["X-Processed"] = "true"
///         return mutable
///     },
///     AnyAsyncMiddleware { request in
///         try? await Task.sleep(nanoseconds: 100_000)
///         return request
///     }
/// ]
///
/// let processed = await processor.process(request)
/// ```
public struct AnyAsyncMiddleware<Input>: AsyncMiddleware {
    @usableFromInline
    let box: (Input) async -> Input

    /// Creates a type-erased async middleware from a concrete async middleware.
    ///
    /// - Parameter middleware: The async middleware to wrap.
    @inlinable
    public init<M: AsyncMiddleware>(_ middleware: M) where M.Input == Input {
        self.box = middleware.process
    }

    /// Creates a type-erased async middleware from a closure.
    ///
    /// - Parameter closure: The async closure that implements the middleware logic.
    @inlinable
    public init(_ closure: @escaping (Input) async -> Input) {
        self.box = closure
    }

    /// Processes the given input value asynchronously.
    ///
    /// - Parameter value: The input value to process.
    /// - Returns: The processed value.
    @inlinable
    public func process(_ value: Input) async -> Input {
        await box(value)
    }
}

extension AnyAsyncMiddleware {
    /// Composes this async middleware with another.
    ///
    /// - Parameter other: The middleware to compose with.
    /// - Returns: A new middleware that applies `self` then `other`.
    @inlinable
    public func composed(with other: AnyAsyncMiddleware<Input>) -> AnyAsyncMiddleware<Input> {
        AnyAsyncMiddleware { value in
            await other.process(self.process(value))
        }
    }
}
