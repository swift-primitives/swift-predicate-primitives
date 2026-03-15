extension Predicate {
    /// Namespace for predicates that test membership.
    public struct In {
        @usableFromInline
        init() {}
    }

    /// Access point for `in`-style predicates like `.in.range(1...10)`.
    public static var `in`: In.Type { In.self }
}

extension Predicate.In where T: Comparable {
    /// Tests whether the value falls within a closed range.
    @inlinable
    public static func range(_ range: ClosedRange<T>) -> Predicate<T> {
        Predicate { range.contains($0) }
    }

    /// Tests whether the value falls within a half-open range.
    @inlinable
    public static func range(_ range: Range<T>) -> Predicate<T> {
        Predicate { range.contains($0) }
    }
}

extension Predicate.In where T: Equatable {
    /// Tests whether the value exists in the collection.
    @inlinable
    public static func collection<C: Collection>(_ collection: C) -> Predicate<T>
    where C.Element == T {
        Predicate { collection.contains($0) }
    }
}
