import Testing

@testable import AnySwift

@Suite("AnyFunction Tests")
struct AnyFunctionTests {
    @Test("calls wrapped function")
    func callsWrappedFunction() {
        let doubler = AnyFunction<Int, Int> { $0 * 2 }
        #expect(doubler(5) == 10)
    }

    @Test("stores multiple functions in array")
    func storesMultipleFunctions() {
        let operations: [AnyFunction<Int, Int>] = [
            AnyFunction { $0 * 2 },
            AnyFunction { $0 + 10 },
            AnyFunction { $0 * $0 }
        ]

        let results = operations.map { $0(5) }
        #expect(results == [10, 15, 25])
    }

    @Test("works as property")
    func worksAsProperty() {
        struct Calculator {
            var operation: AnyFunction<Int, Int>

            func calculate(_ input: Int) -> Int {
                operation(input)
            }
        }

        let calc = Calculator(operation: AnyFunction { $0 * 3 })
        #expect(calc.calculate(4) == 12)
    }
}
