/// A protocol for transforming values from one type to another.
///
/// Mappers are used to convert between domain models, DTOs, and entity models
/// in layered architectures.
///
/// ## Example
/// ```swift
/// struct UserDTOMapper: Mapper {
///     func map(_ dto: UserDTO) -> User {
///         User(
///             id: dto.id,
///             name: dto.name,
///             email: dto.email
///         )
///     }
/// }
/// ```
public protocol Mapper<Input, Output> {
    associatedtype Input
    associatedtype Output

    /// Transforms the input value to the output type.
    ///
    /// - Parameter input: The value to transform.
    /// - Returns: The transformed value.
    func map(_ input: Input) -> Output
}

/// A protocol for async value transformation.
public protocol AsyncMapper<Input, Output> {
    associatedtype Input
    associatedtype Output

    /// Transforms the input value to the output type asynchronously.
    ///
    /// - Parameter input: The value to transform.
    /// - Returns: The transformed value.
    func map(_ input: Input) async -> Output
}
