/// A protocol for validating input values.
///
/// Validators encapsulate validation logic and can be composed to create
/// complex validation rules.
///
/// ## Example
/// ```swift
/// struct EmailValidator: Validator {
///     func validate(_ email: String) -> ValidationResult {
///         let regex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/
///         return regex.matches(email)
///             ? .valid
///             : .invalid("Invalid email format")
///     }
/// }
/// ```
public protocol Validator<Input> {
    associatedtype Input

    /// Validates the given input.
    ///
    /// - Parameter input: The value to validate.
    /// - Returns: A `ValidationResult` indicating success or failure.
    func validate(_ input: Input) -> ValidationResult
}

/// The result of a validation operation.
public enum ValidationResult: Equatable {
    case valid
    case invalid(String)

    /// Returns `true` if the validation succeeded.
    public var isValid: Bool {
        if case .valid = self { return true }
        return false
    }

    /// Returns the error message if validation failed.
    public var errorMessage: String? {
        if case .invalid(let message) = self { return message }
        return nil
    }
}
