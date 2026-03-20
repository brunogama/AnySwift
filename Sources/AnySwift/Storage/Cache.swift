/// A protocol that defines a cache for storing and retrieving values.
///
/// Caches provide temporary storage with optional expiration policies.
///
/// ## Example
/// ```swift
/// struct ImageCache: Cache {
///     private var storage: [String: UIImage] = [:]
///
///     func get(_ key: String) -> UIImage? {
///         storage[key]
///     }
///
///     func set(_ value: UIImage, forKey key: String) {
///         storage[key] = value
///     }
///
///     func remove(_ key: String) {
///         storage.removeValue(forKey: key)
///     }
///
///     func clear() {
///         storage.removeAll()
///     }
/// }
/// ```
public protocol Cache<Key, Value> {
    associatedtype Key: Hashable
    associatedtype Value

    /// Retrieves a value from the cache.
    func get(_ key: Key) -> Value?

    /// Stores a value in the cache.
    func set(_ value: Value, forKey key: Key)

    /// Removes a value from the cache.
    func remove(_ key: Key)

    /// Clears all values from the cache.
    func clear()

    /// Checks if a key exists in the cache.
    func contains(_ key: Key) -> Bool
}
