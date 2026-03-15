extension Predicate {
    /// Namespace for predicates that test possession of properties.
    public struct Has {
        @usableFromInline
        init() {}
    }

    /// Access point for `has`-style predicates like `.has.prefix("foo")`.
    public static var has: Has.Type { Has.self }
}

extension Predicate.Has where T: StringProtocol {
    /// Tests whether the string starts with the given prefix.
    @inlinable
    public static func prefix(_ prefix: String) -> Predicate<T> {
        Predicate { $0.hasPrefix(prefix) }
    }

    /// Tests whether the string ends with the given suffix.
    @inlinable
    public static func suffix(_ suffix: String) -> Predicate<T> {
        Predicate { $0.hasSuffix(suffix) }
    }
}

extension Predicate.Has where T: Collection {
    /// Tests whether the collection has exactly the specified count.
    @inlinable
    public static func count(_ count: Int) -> Predicate<T> {
        Predicate { $0.count == count }
    }
}

extension Predicate.Has where T: Identifiable {
    /// Tests whether the value has the specified identifier.
    @inlinable
    public static func id(_ id: T.ID) -> Predicate<T> {
        Predicate { $0.id == id }
    }

    /// Tests whether the value's identifier exists in the collection.
    @inlinable
    public static func id<C: Collection>(in ids: C) -> Predicate<T> where C.Element == T.ID {
        Predicate { ids.contains($0.id) }
    }
}
