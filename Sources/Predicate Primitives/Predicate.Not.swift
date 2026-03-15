extension Predicate {
    /// Namespace for negated predicates.
    public struct Not {
        @usableFromInline
        init() {}
    }

    /// Access point for `not`-style predicates like `.not.equalTo(0)`.
    public static var not: Not.Type { Not.self }
}

extension Predicate.Not where T: Equatable {
    /// Tests whether the value does not equal the target.
    @inlinable
    public static func equalTo(_ value: T) -> Predicate<T> {
        Predicate { $0 != value }
    }
}

extension Predicate.Not where T: Comparable {
    /// Tests whether the value falls outside the closed range.
    @inlinable
    public static func inRange(_ range: ClosedRange<T>) -> Predicate<T> {
        Predicate { !range.contains($0) }
    }

    /// Tests whether the value falls outside the half-open range.
    @inlinable
    public static func inRange(_ range: Range<T>) -> Predicate<T> {
        Predicate { !range.contains($0) }
    }
}
