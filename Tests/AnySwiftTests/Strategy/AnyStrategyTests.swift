import Testing

@testable import AnySwift

@Suite("AnyStrategy Tests")
struct AnyStrategyTests {
    @Test("executes strategy")
    func executesStrategy() {
        let doubleStrategy = AnyStrategy<Int, Int> { $0 * 2 }
        #expect(doubleStrategy.execute(5) == 10)
    }

    @Test("creates from concrete strategy")
    func createsFromConcreteStrategy() {
        struct AddStrategy: Strategy {
            let value: Int

            func execute(_ input: Int) -> Int {
                input + value
            }
        }

        let strategy = AnyStrategy(AddStrategy(value: 10))
        #expect(strategy.execute(5) == 15)
    }

    @Test("works in struct property")
    func worksInStructProperty() {
        struct Calculator {
            var strategy: AnyStrategy<Int, Int>

            func calculate(_ input: Int) -> Int {
                strategy.execute(input)
            }
        }

        let calc = Calculator(strategy: AnyStrategy { $0 * 3 })
        #expect(calc.calculate(4) == 12)
    }

    @Test("multiple strategies in array")
    func multipleStrategiesInArray() {
        let strategies: [AnyStrategy<Int, Int>] = [
            AnyStrategy { $0 * 2 },
            AnyStrategy { $0 + 10 },
            AnyStrategy { $0 * $0 }
        ]

        let results = strategies.map { $0.execute(5) }
        #expect(results == [10, 15, 25])
    }
}
