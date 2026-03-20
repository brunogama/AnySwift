import Foundation

/// A type-erased cache wrapper.
///
/// Use `AnyCache` to work with different cache implementations polymorphically.
///
/// ## Example
/// ```swift
/// struct DataManager {
///     var cache: AnyCache<String, Data>
///
///     func fetchData(key: String) async -> Data {
///         if let cached = cache.get(key) {
///             return cached
///         }
///         let data = await downloadData(key: key)
///         cache.set(data, forKey: key)
///         return data
///     }
/// }
/// ```
public struct AnyCache<Key: Hashable, Value>: Cache {
    @usableFromInline
    let getBox: (Key) -> Value?
    @usableFromInline
    let setBox: (Value, Key) -> Void
    @usableFromInline
    let removeBox: (Key) -> Void
    @usableFromInline
    let clearBox: () -> Void
    @usableFromInline
    let containsBox: (Key) -> Bool

    @inlinable
    public init<C: Cache>(_ cache: C) where C.Key == Key, C.Value == Value {
        self.getBox = cache.get
        self.setBox = cache.set
        self.removeBox = cache.remove
        self.clearBox = cache.clear
        self.containsBox = cache.contains
    }

    @inlinable
    public init(
        get: @escaping (Key) -> Value?,
        set: @escaping (Value, Key) -> Void,
        remove: @escaping (Key) -> Void,
        clear: @escaping () -> Void,
        contains: @escaping (Key) -> Bool
    ) {
        self.getBox = get
        self.setBox = set
        self.removeBox = remove
        self.clearBox = clear
        self.containsBox = contains
    }

    @inlinable
    public func get(_ key: Key) -> Value? {
        getBox(key)
    }

    @inlinable
    public func set(_ value: Value, forKey key: Key) {
        setBox(value, key)
    }

    @inlinable
    public func remove(_ key: Key) {
        removeBox(key)
    }

    @inlinable
    public func clear() {
        clearBox()
    }

    @inlinable
    public func contains(_ key: Key) -> Bool {
        containsBox(key)
    }
}

/// A thread-safe wrapper for any cache.
public final class ThreadSafeCache<Key: Hashable, Value>: Cache {
    private let cache: AnyCache<Key, Value>
    private let lock = NSLock()

    public init<C: Cache>(_ cache: C) where C.Key == Key, C.Value == Value {
        self.cache = AnyCache(cache)
    }

    public func get(_ key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }
        return cache.get(key)
    }

    public func set(_ value: Value, forKey key: Key) {
        lock.lock()
        defer { lock.unlock() }
        cache.set(value, forKey: key)
    }

    public func remove(_ key: Key) {
        lock.lock()
        defer { lock.unlock() }
        cache.remove(key)
    }

    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        cache.clear()
    }

    public func contains(_ key: Key) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return cache.contains(key)
    }
}
