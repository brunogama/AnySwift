# Strategy Pattern

Type-erased wrappers for strategy and predicate patterns.

## Overview

The Strategy pattern encapsulates algorithms and makes them interchangeable. AnySwift provides type-erased wrappers that let you work with different strategy implementations polymorphically.

## Types

### ``AnyStrategy``

A type-erased strategy wrapper.

```swift
struct PricingEngine {
    var strategy: AnyStrategy<Double, Double>

    func calculatePrice(_ basePrice: Double) -> Double {
        strategy.execute(basePrice)
    }
}

// Regular price
let regular = PricingEngine(strategy: AnyStrategy { $0 })

// 10% discount
let discount = PricingEngine(strategy: AnyStrategy { $0 * 0.9 })

// Buy one get one half off
let bogo = PricingEngine(strategy: AnyStrategy { $0 * 1.5 })
```

### ``AnyPredicate``

A type-erased predicate wrapper with logical composition operators.

```swift
struct ProductFilter {
    var predicates: [AnyPredicate<Product>] = []

    func matches(_ product: Product) -> Bool {
        predicates.allSatisfy { $0.test(product) }
    }
}

var filter = ProductFilter()
filter.predicates = [
    AnyPredicate { $0.price < 100 },
    AnyPredicate { !$0.name.isEmpty },
    AnyPredicate { $0.inStock }
]

// Composition
let priceFilter = AnyPredicate<Product> { $0.price < 50 }
let inStockFilter = AnyPredicate<Product> { $0.inStock }
let affordableAvailable = priceFilter.and(inStockFilter)
```

## Use Cases

### Dynamic Pricing

Change pricing strategies based on customer segment:

```swift
enum CustomerSegment {
    case regular, premium, student
}

func pricingStrategy(for segment: CustomerSegment) -> AnyStrategy<Double, Double> {
    switch segment {
    case .regular:
        return AnyStrategy { $0 }
    case .premium:
        return AnyStrategy { $0 * 0.85 } // 15% off
    case .student:
        return AnyStrategy { $0 * 0.90 } // 10% off
    }
}
```

### Validation

Compose validation rules dynamically:

```swift
struct Validator<T> {
    var rules: [AnyPredicate<T>] = []

    func validate(_ value: T) -> Bool {
        rules.allSatisfy { $0.test(value) }
    }
}

let passwordValidator = Validator<String>(
    rules: [
        AnyPredicate { $0.count >= 8 },
        AnyPredicate { $0.rangeOfCharacter(from: .uppercaseLetters) != nil },
        AnyPredicate { $0.rangeOfCharacter(from: .decimalDigits) != nil }
    ]
)
```

### Filtering

Build complex filters with composition:

```swift
let recent = AnyPredicate<Document> { $0.date > Date().addingTimeInterval(-86400) }
let important = AnyPredicate<Document> { $0.priority == .high }
let unread = AnyPredicate<Document> { !$0.isRead }

// Combine predicates
let urgentDocuments = recent.and(important).and(unread)
```
