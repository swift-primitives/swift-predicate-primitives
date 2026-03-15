extension Predicate {
    /// Namespace for count-based array quantifiers.
    public struct Count {
        @usableFromInline
        let predicate: Predicate

        @usableFromInline
        init(_ predicate: Predicate) {
            self.predicate = predicate
        }
    }

    /// Access point for count quantifiers like `.count.atLeast(2)`.
    @inlinable
    public var count: Count { Count(self) }
}

extension Predicate.Count {
    /// Tests whether at least N array elements satisfy the predicate.
    @inlinable
    public static func atLeast(_ predicate: Predicate, _ n: Int) -> Predicate<[T]> {
        Predicate<[T]> { array in
            var count = 0
            for element in array {
                if predicate.evaluate(element) {
                    count += 1
                    if count >= n { return true }
                }
            }
            return false
        }
    }

    /// Tests whether at most N array elements satisfy the predicate.
    @inlinable
    public static func atMost(_ predicate: Predicate, _ n: Int) -> Predicate<[T]> {
        Predicate<[T]> { array in
            var count = 0
            for element in array {
                if predicate.evaluate(element) {
                    count += 1
                    if count > n { return false }
                }
            }
            return true
        }
    }

    /// Tests whether exactly N array elements satisfy the predicate.
    @inlinable
    public static func exactly(_ predicate: Predicate, _ n: Int) -> Predicate<[T]> {
        Predicate<[T]> { array in
            var count = 0
            for element in array {
                if predicate.evaluate(element) {
                    count += 1
                    if count > n { return false }
                }
            }
            return count == n
        }
    }

    /// Tests whether zero array elements satisfy the predicate.
    @inlinable
    public static func zero(_ predicate: Predicate) -> Predicate<[T]> {
        Self.exactly(predicate, 0)
    }

    /// Tests whether exactly one array element satisfies the predicate.
    @inlinable
    public static func one(_ predicate: Predicate) -> Predicate<[T]> {
        Self.exactly(predicate, 1)
    }

    /// Tests whether at least N array elements satisfy the predicate.
    @inlinable
    public func atLeast(_ n: Int) -> Predicate<[T]> {
        Self.atLeast(self.predicate, n)
    }

    /// Tests whether at most N array elements satisfy the predicate.
    @inlinable
    public func atMost(_ n: Int) -> Predicate<[T]> {
        Self.atMost(self.predicate, n)
    }

    /// Tests whether exactly N array elements satisfy the predicate.
    @inlinable
    public func exactly(_ n: Int) -> Predicate<[T]> {
        Self.exactly(self.predicate, n)
    }

    /// Tests whether zero array elements satisfy the predicate.
    @inlinable
    public var zero: Predicate<[T]> {
        Self.zero(self.predicate)
    }

    /// Tests whether exactly one array element satisfies the predicate.
    @inlinable
    public var one: Predicate<[T]> {
        Self.one(self.predicate)
    }
}
