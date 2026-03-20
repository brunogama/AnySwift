import Testing

@testable import AnySwift

@Suite("AnyMiddleware Tests")
struct AnyMiddlewareTests {
    @Test("processes value")
    func processesValue() {
        let addTen = AnyMiddleware<Int> { $0 + 10 }
        #expect(addTen.process(5) == 15)
    }

    @Test("creates from concrete middleware")
    func createsFromConcreteMiddleware() {
        struct PrefixMiddleware: Middleware {
            let prefix: String

            func process(_ value: String) -> String {
                prefix + value
            }
        }

        let middleware = AnyMiddleware(PrefixMiddleware(prefix: "test_"))
        #expect(middleware.process("value") == "test_value")
    }

    @Test("multiple middlewares in array")
    func multipleMiddlewaresInArray() {
        let middlewares: [AnyMiddleware<Int>] = [
            AnyMiddleware { $0 + 10 },
            AnyMiddleware { $0 * 2 }
        ]

        let result = middlewares.reduce(5) { value, middleware in
            middleware.process(value)
        }
        #expect(result == 30)  // (5 + 10) * 2
    }

    @Test("composition")
    func composition() {
        let addFive = AnyMiddleware<Int> { $0 + 5 }
        let multiplyByTwo = AnyMiddleware<Int> { $0 * 2 }

        let composed = addFive.composed(with: multiplyByTwo)

        #expect(composed.process(3) == 16)  // (3 + 5) * 2
    }
}
