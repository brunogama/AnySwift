import Testing

@testable import AnySwift

@Suite("AnyAsyncFactory Tests")
struct AnyAsyncFactoryTests {
    @Test("creates instance async")
    func createsInstanceAsync() async {
        let factory = AnyAsyncFactory {
            await Task.yield()
            return "async_result"
        }

        let result = await factory.create()
        #expect(result == "async_result")
    }

    @Test("creates from concrete async factory")
    func createsFromConcreteAsyncFactory() async {
        struct AsyncIntFactory: AsyncFactory {
            let multiplier: Int

            func create() async -> Int {
                await Task.yield()
                return 10 * multiplier
            }
        }

        let factory = AnyAsyncFactory(AsyncIntFactory(multiplier: 5))
        let result = await factory.create()
        #expect(result == 50)
    }

    @Test("works in struct property")
    func worksInStructProperty() async {
        struct AsyncContainer {
            var factory: AnyAsyncFactory<String>

            func makeValue() async -> String {
                await factory.create()
            }
        }

        let container = AsyncContainer(
            factory: AnyAsyncFactory {
                await Task.yield()
                return "created"
            }
        )

        let result = await container.makeValue()
        #expect(result == "created")
    }
}
