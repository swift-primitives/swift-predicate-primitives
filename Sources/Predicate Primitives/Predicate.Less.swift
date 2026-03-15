extension Predicate {
    /// Namespace for predicates that test relative magnitude.
    public struct Less {
        @usableFromInline
        init() {}
    }

    /// Access point for `less`-style predicates like `.less.than(10)`.
    public static var less: Less.Type { Less.self }
}

extension Predicate.Less where T: Comparable {
    /// Tests whether the value is less than the threshold.
    @inlinable
    public static func than(_ value: T) -> Predicate<T> {
        Predicate { $0 < value }
    }

    /// Tests whether the value is less than or equal to the threshold.
    @inlinable
    public static func thanOrEqualTo(_ value: T) -> Predicate<T> {
        Predicate { $0 <= value }
    }
}
