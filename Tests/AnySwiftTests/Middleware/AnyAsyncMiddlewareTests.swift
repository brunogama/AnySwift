import Testing

@testable import AnySwift

@Suite("AnyAsyncMiddleware Tests")
struct AnyAsyncMiddlewareTests {
    @Test("processes value async")
    func processesValueAsync() async {
        let middleware = AnyAsyncMiddleware<Int> { value in
            await Task.yield()
            return value + 10
        }

        let result = await middleware.process(5)
        #expect(result == 15)
    }

    @Test("creates from concrete async middleware")
    func createsFromConcreteAsyncMiddleware() async {
        struct AsyncLoggingMiddleware: AsyncMiddleware {
            func process(_ value: String) async -> String {
                await Task.yield()
                return value + "_processed"
            }
        }

        let middleware = AnyAsyncMiddleware(AsyncLoggingMiddleware())
        let result = await middleware.process("input")
        #expect(result == "input_processed")
    }

    @Test("multiple async middlewares")
    func multipleAsyncMiddlewares() async {
        let middlewares: [AnyAsyncMiddleware<Int>] = [
            AnyAsyncMiddleware { value in
                await Task.yield()
                return value + 5
            },
            AnyAsyncMiddleware { value in
                await Task.yield()
                return value * 2
            }
        ]

        var result = 3
        for middleware in middlewares {
            result = await middleware.process(result)
        }

        #expect(result == 16)  // (3 + 5) * 2
    }

    @Test("async composition")
    func asyncComposition() async {
        let addFive = AnyAsyncMiddleware<Int> { value in
            await Task.yield()
            return value + 5
        }

        let multiplyByTwo = AnyAsyncMiddleware<Int> { value in
            await Task.yield()
            return value * 2
        }

        let composed = addFive.composed(with: multiplyByTwo)

        let result = await composed.process(3)
        #expect(result == 16)  // (3 + 5) * 2
    }
}
