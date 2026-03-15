extension Predicate {
    /// Namespace for predicates that test identity and state.
    public struct Is {
        @usableFromInline
        init() {}
    }

    /// Access point for `is`-style predicates like `.is.empty`.
    public static var `is`: Is.Type { Is.self }
}

extension Predicate.Is where T: Collection {
    /// Tests whether the collection is empty.
    @inlinable
    public static var empty: Predicate<T> {
        Predicate { $0.isEmpty }
    }

    /// Tests whether the collection contains elements.
    @inlinable
    public static var notEmpty: Predicate<T> {
        Predicate { !$0.isEmpty }
    }
}

extension Predicate.Is {
    /// Tests whether the optional is `nil`.
    @inlinable
    public static var `nil`: Predicate<T?> {
        Predicate<T?> { $0 == nil }
    }

    /// Tests whether the optional contains a value.
    @inlinable
    public static var notNil: Predicate<T?> {
        Predicate<T?> { $0 != nil }
    }
}
