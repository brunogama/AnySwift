/// A type-erased validator wrapper.
///
/// Use `AnyValidator` to compose and work with different validation rules.
///
/// ## Example
/// ```swift
/// let emailValidator = AnyValidator<String> { email in
///     email.contains("@") ? .valid : .invalid("Missing @")
/// }
///
/// let result = emailValidator.validate("test@example.com")
/// ```
public struct AnyValidator<Input>: Validator {
    @usableFromInline
    let box: (Input) -> ValidationResult

    @inlinable
    public init<V: Validator>(_ validator: V) where V.Input == Input {
        self.box = validator.validate
    }

    @inlinable
    public init(_ closure: @escaping (Input) -> ValidationResult) {
        self.box = closure
    }

    @inlinable
    public func validate(_ input: Input) -> ValidationResult {
        box(input)
    }
}

extension AnyValidator {
    /// Combines this validator with another using AND logic.
    @inlinable
    public func and(_ other: AnyValidator<Input>) -> AnyValidator<Input> {
        AnyValidator { input in
            let firstResult = self.validate(input)
            if !firstResult.isValid {
                return firstResult
            }
            return other.validate(input)
        }
    }

    /// Combines this validator with another using OR logic.
    @inlinable
    public func or(_ other: AnyValidator<Input>) -> AnyValidator<Input> {
        AnyValidator { input in
            let firstResult = self.validate(input)
            if firstResult.isValid {
                return .valid
            }
            let secondResult = other.validate(input)
            if secondResult.isValid {
                return .valid
            }
            return secondResult
        }
    }

    /// Creates a validator that negates this validator's result.
    @inlinable
    public func negated() -> AnyValidator<Input> {
        AnyValidator { input in
            let result = self.validate(input)
            return result.isValid
                ? .invalid("Validation should not pass")
                : .valid
        }
    }
}

/// A composite validator that runs multiple validators.
public struct CompositeValidator<Input>: Validator {
    @usableFromInline
    let validators: [AnyValidator<Input>]

    public init(validators: [AnyValidator<Input>]) {
        self.validators = validators
    }

    public func validate(_ input: Input) -> ValidationResult {
        for validator in validators {
            let result = validator.validate(input)
            if !result.isValid {
                return result
            }
        }
        return .valid
    }
}
