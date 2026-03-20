import Testing

@testable import AnySwift

@Suite("AnyPredicate Tests")
struct AnyPredicateTests {
    @Test("tests predicate")
    func testsPredicate() {
        let isEven = AnyPredicate<Int> { $0 % 2 == 0 }
        #expect(isEven.test(4) == true)
        #expect(isEven.test(5) == false)
    }

    @Test("creates from concrete predicate")
    func createsFromConcretePredicate() {
        struct GreaterThanPredicate: Predicate {
            let threshold: Int

            func test(_ element: Int) -> Bool {
                element > threshold
            }
        }

        let predicate = AnyPredicate(GreaterThanPredicate(threshold: 10))
        #expect(predicate.test(15) == true)
        #expect(predicate.test(5) == false)
    }

    @Test("and composition")
    func andComposition() {
        let isPositive = AnyPredicate<Int> { $0 > 0 }
        let isEven = AnyPredicate<Int> { $0 % 2 == 0 }

        let positiveAndEven = isPositive.and(isEven)

        #expect(positiveAndEven.test(4) == true)
        #expect(positiveAndEven.test(-4) == false)
        #expect(positiveAndEven.test(3) == false)
    }

    @Test("or composition")
    func orComposition() {
        let isNegative = AnyPredicate<Int> { $0 < 0 }
        let isZero = AnyPredicate<Int> { $0 == 0 }

        let negativeOrZero = isNegative.or(isZero)

        #expect(negativeOrZero.test(-5) == true)
        #expect(negativeOrZero.test(0) == true)
        #expect(negativeOrZero.test(5) == false)
    }

    @Test("negated")
    func negated() {
        let isEven = AnyPredicate<Int> { $0 % 2 == 0 }
        let isOdd = isEven.negated()

        #expect(isOdd.test(3) == true)
        #expect(isOdd.test(4) == false)
    }

    @Test("chained composition")
    func chainedComposition() {
        let isPositive = AnyPredicate<Int> { $0 > 0 }
        let isEven = AnyPredicate<Int> { $0 % 2 == 0 }
        let isLessThanHundred = AnyPredicate<Int> { $0 < 100 }

        let complexPredicate = isPositive.and(isEven).and(isLessThanHundred)

        #expect(complexPredicate.test(50) == true)
        #expect(complexPredicate.test(150) == false)
        #expect(complexPredicate.test(51) == false)
    }
}
