import Testing

@testable import AnySwift

@Suite("AnyAsyncThrowingFunction Tests")
struct AnyAsyncThrowingFunctionTests {
    enum TestError: Error {
        case networkFailure
        case decodingFailed
    }

    @Test("calls async throwing function successfully")
    func callsAsyncThrowingFunctionSuccessfully() async throws {
        let processor = AnyAsyncThrowingFunction<String, Int> { input in
            await Task.yield()
            guard let value = Int(input) else {
                throw TestError.decodingFailed
            }
            return value
        }

        let result = try await processor("42")
        #expect(result == 42)
    }

    @Test("throws error from async function")
    func throwsErrorFromAsyncFunction() async {
        let processor = AnyAsyncThrowingFunction<String, Int> { _ in
            await Task.yield()
            throw TestError.networkFailure
        }

        await #expect(throws: TestError.networkFailure) {
            try await processor("test")
        }
    }

    @Test("works in struct property")
    func worksInStructProperty() async throws {
        struct APIClient {
            var request: AnyAsyncThrowingFunction<String, String>
        }

        let client = APIClient(
            request: AnyAsyncThrowingFunction { input in
                await Task.yield()
                return "Response: \(input)"
            }
        )

        let result = try await client.request("query")
        #expect(result == "Response: query")
    }
}
