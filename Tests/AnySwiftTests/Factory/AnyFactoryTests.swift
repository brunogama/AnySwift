import Testing

@testable import AnySwift

@Suite("AnyFactory Tests")
struct AnyFactoryTests {
    @Test("creates instance")
    func createsInstance() {
        let factory = AnyFactory { 42 }
        #expect(factory.create() == 42)
    }

    @Test("creates from concrete factory")
    func createsFromConcreteFactory() {
        struct StringFactory: Factory {
            let prefix: String

            func create() -> String {
                prefix + "_instance"
            }
        }

        let factory = AnyFactory(StringFactory(prefix: "test"))
        #expect(factory.create() == "test_instance")
    }

    @Test("works in struct property")
    func worksInStructProperty() {
        struct Container {
            var factory: AnyFactory<Int>

            func makeValue() -> Int {
                factory.create()
            }
        }

        let container = Container(factory: AnyFactory { 100 })
        #expect(container.makeValue() == 100)
    }

    @Test("creates different types")
    func createsDifferentTypes() {
        struct Item {
            let id: Int
            let name: String
        }

        let factories: [AnyFactory<Item>] = [
            AnyFactory { Item(id: 1, name: "A") },
            AnyFactory { Item(id: 2, name: "B") }
        ]

        let items = factories.map { $0.create() }
        #expect(items[0].id == 1)
        #expect(items[1].name == "B")
    }
}
