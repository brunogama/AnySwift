import Testing

@testable import AnySwift

@Suite("AnyAsyncSequence Tests")
struct AnyAsyncSequenceTests {
    @Test("iterates sequence")
    func iteratesSequence() async {
        let stream = AsyncStream<Int> { continuation in
            continuation.yield(1)
            continuation.yield(2)
            continuation.yield(3)
            continuation.finish()
        }

        let sequence = AnyAsyncSequence(stream)

        var collected: [Int] = []
        for await value in sequence {
            collected.append(value)
        }

        #expect(collected == [1, 2, 3])
    }

    @Test("creates from closure")
    func createsFromClosure() async {
        var values = ["a", "b", "c"].makeIterator()
        let sequence = AnyAsyncSequence<String> {
            AnyAsyncIterator {
                values.next()
            }
        }

        var collected: [String] = []
        for await value in sequence {
            collected.append(value)
        }

        #expect(collected == ["a", "b", "c"])
    }

    @Test("eraseToAnyAsyncSequence extension")
    func eraseToAnyAsyncSequenceExtension() async {
        let stream = AsyncStream<Int> { continuation in
            continuation.yield(10)
            continuation.finish()
        }

        let erased = stream.eraseToAnyAsyncSequence()

        var collected: [Int] = []
        for await value in erased {
            collected.append(value)
        }

        #expect(collected == [10])
    }

    @Test("empty sequence")
    func emptySequence() async {
        let sequence = AnyAsyncSequence<Int> {
            AnyAsyncIterator { nil }
        }

        var count = 0
        for await _ in sequence {
            count += 1
        }

        #expect(count == 0)
    }

    @Test("creates new iterator each iteration")
    func createsNewIteratorEachIteration() async {
        // Use a closure-based sequence that creates fresh state each time
        let sequence = AnyAsyncSequence<Int> {
            var counter = 0
            return AnyAsyncIterator {
                counter += 1
                if counter <= 3 {
                    return counter
                }
                return nil
            }
        }

        var firstCollected: [Int] = []
        for await value in sequence {
            firstCollected.append(value)
        }

        var secondCollected: [Int] = []
        for await value in sequence {
            secondCollected.append(value)
        }

        #expect(firstCollected == [1, 2, 3])
        #expect(secondCollected == [1, 2, 3])
    }
}
