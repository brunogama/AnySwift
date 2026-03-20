import Testing

@testable import AnySwift

@Suite("AnyAsyncFunction Tests")
struct AnyAsyncFunctionTests {
  @Test("calls async function")
  func callsAsyncFunction() async {
    let fetcher = AnyAsyncFunction<Int, String> { input in
      await Task.yield()
      return "Result: \(input)"
    }

    let result = await fetcher(42)
    #expect(result == "Result: 42")
  }

  @Test("works with async data")
  func worksWithAsyncData() async {
    struct DataLoader {
      var fetch: AnyAsyncFunction<String, String>
    }

    let loader = DataLoader(
      fetch: AnyAsyncFunction { input in
        await Task.yield()
        return "Fetched: \(input)"
      }
    )

    let result = await loader.fetch("test")
    #expect(result == "Fetched: test")
  }

  @Test("multiple async functions in array")
  func multipleAsyncFunctionsInArray() async {
    let operations: [AnyAsyncFunction<Int, Int>] = [
      AnyAsyncFunction {
        await Task.yield()
        return $0 * 2
      },
      AnyAsyncFunction {
        await Task.yield()
        return $0 + 10
      },
    ]

    var results: [Int] = []
    for operation in operations {
      results.append(await operation(5))
    }

    results.sort()

    #expect(results == [10, 15])
  }
}
