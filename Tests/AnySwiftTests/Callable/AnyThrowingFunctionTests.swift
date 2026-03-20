import Testing

@testable import AnySwift

@Suite("AnyThrowingFunction Tests")
struct AnyThrowingFunctionTests {
    enum TestError: Error {
        case validationFailed
    }

    @Test("calls throwing function successfully")
    func callsThrowingFunctionSuccessfully() throws {
        let validator = AnyThrowingFunction<String, String> { input in
            guard !input.isEmpty else {
                throw TestError.validationFailed
            }
            return input
        }

        let result = try validator("hello")
        #expect(result == "hello")
    }

    @Test("throws error correctly")
    func throwsErrorCorrectly() {
        let validator = AnyThrowingFunction<String, String> { input in
            guard !input.isEmpty else {
                throw TestError.validationFailed
            }
            return input
        }

        #expect(throws: TestError.validationFailed) {
            try validator("")
        }
    }

    @Test("stores multiple validators")
    func storesMultipleValidators() throws {
        let validators: [AnyThrowingFunction<Int, Int>] = [
            AnyThrowingFunction { $0 },
            AnyThrowingFunction { value in
                if value < 0 {
                    throw TestError.validationFailed
                }
                return value
            }
        ]

        #expect(throws: TestError.validationFailed) {
            try validators[1](-1)
        }

        let result = try validators[1](5)
        #expect(result == 5)
    }
}
