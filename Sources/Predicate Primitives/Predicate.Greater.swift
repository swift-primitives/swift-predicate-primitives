extension Predicate {
    /// Namespace for predicates that test relative magnitude.
    public struct Greater {
        @usableFromInline
        init() {}
    }

    /// Access point for `greater`-style predicates like `.greater.than(5)`.
    public static var greater: Greater.Type { Greater.self }
}

extension Predicate.Greater where T: Comparable {
    /// Tests whether the value is greater than the threshold.
    @inlinable
    public static func than(_ value: T) -> Predicate<T> {
        Predicate { $0 > value }
    }

    /// Tests whether the value is greater than or equal to the threshold.
    @inlinable
    public static func thanOrEqualTo(_ value: T) -> Predicate<T> {
        Predicate { $0 >= value }
    }
}
