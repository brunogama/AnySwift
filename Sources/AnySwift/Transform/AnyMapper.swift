/// A type-erased mapper wrapper.
///
/// Use `AnyMapper` to work with different mapping implementations polymorphically.
///
/// ## Example
/// ```swift
/// struct UserService {
///     var userMapper: AnyMapper<UserDTO, User>
///
///     func convert(dto: UserDTO) -> User {
///         userMapper.map(dto)
///     }
/// }
///
/// // Production
/// let service = UserService(
///     userMapper: AnyMapper { User(from: $0) }
/// )
/// ```
public struct AnyMapper<Input, Output>: Mapper {
    @usableFromInline
    let box: (Input) -> Output

    /// Creates a type-erased mapper from a concrete mapper.
    @inlinable
    public init<M: Mapper>(_ mapper: M) where M.Input == Input, M.Output == Output {
        self.box = mapper.map
    }

    /// Creates a type-erased mapper from a closure.
    @inlinable
    public init(_ closure: @escaping (Input) -> Output) {
        self.box = closure
    }

    @inlinable
    public func map(_ input: Input) -> Output {
        box(input)
    }
}

/// A type-erased async mapper wrapper.
public struct AnyAsyncMapper<Input, Output>: AsyncMapper {
    @usableFromInline
    let box: (Input) async -> Output

    @inlinable
    public init<M: AsyncMapper>(_ mapper: M) where M.Input == Input, M.Output == Output {
        self.box = mapper.map
    }

    @inlinable
    public init(_ closure: @escaping (Input) async -> Output) {
        self.box = closure
    }

    @inlinable
    public func map(_ input: Input) async -> Output {
        await box(input)
    }
}

extension AnyMapper {
    /// Maps a collection of inputs to outputs.
    @inlinable
    public func mapCollection(_ inputs: [Input]) -> [Output] {
        inputs.map(box)
    }
}

extension AnyAsyncMapper {
    /// Maps a collection of inputs to outputs asynchronously (sequential).
    @inlinable
    public func mapCollection(_ inputs: [Input]) async -> [Output] {
        var results: [Output] = []
        for input in inputs {
            let output = await self.map(input)
            results.append(output)
        }
        return results
    }
}
