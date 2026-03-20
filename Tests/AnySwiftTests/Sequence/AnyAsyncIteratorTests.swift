import Testing

@testable import AnySwift

@Suite("AnyAsyncIterator Tests")
struct AnyAsyncIteratorTests {
    @Test("iterates async values")
    func iteratesAsyncValues() async {
        var values = [1, 2, 3].makeIterator()
        let iterator = AnyAsyncIterator<Int> {
            values.next()
        }

        var collected: [Int] = []
        var mutableIterator = iterator
        while let value = await mutableIterator.next() {
            collected.append(value)
        }

        #expect(collected == [1, 2, 3])
    }

    @Test("creates from concrete iterator")
    func createsFromConcreteIterator() async {
        let asyncStream = AsyncStream<Int> { continuation in
            continuation.yield(10)
            continuation.yield(20)
            continuation.finish()
        }

        var iterator = AnyAsyncIterator(asyncStream.makeAsyncIterator())

        #expect(await iterator.next() == 10)
        #expect(await iterator.next() == 20)
        #expect(await iterator.next() == nil)
    }

    @Test("empty iterator")
    func emptyIterator() async {
        let iterator = AnyAsyncIterator<Int> { nil }
        var mutableIterator = iterator

        let value = await mutableIterator.next()
        #expect(value == nil)
    }
}
