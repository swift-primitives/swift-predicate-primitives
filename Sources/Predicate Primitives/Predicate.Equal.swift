extension Predicate {
    /// Namespace for predicates that test equality.
    public struct Equal {
        @usableFromInline
        init() {}
    }

    /// Access point for `equal`-style predicates like `.equal.to(42)`.
    public static var equal: Equal.Type { Equal.self }
}

extension Predicate.Equal where T: Equatable {
    /// Tests whether the value equals the target.
    @inlinable
    public static func to(_ value: T) -> Predicate<T> {
        Predicate { $0 == value }
    }

    /// Tests whether the value equals any of the targets.
    @inlinable
    public static func toAny(of values: T...) -> Predicate<T> {
        Predicate { values.contains($0) }
    }

    /// Tests whether the value equals none of the targets.
    @inlinable
    public static func toNone(of values: T...) -> Predicate<T> {
        Predicate { !values.contains($0) }
    }
}
