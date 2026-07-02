// Predicate.swift
// A composable boolean test on values of type T.

// WHY: Category D — structural Sendable workaround (SP-4).
// WHY: Holds `var evaluate: (T) -> Bool` — a non-@Sendable closure. @unchecked
// WHY: exists because the closure storage blocks structural inference. Could be
// WHY: fixed by making the closure `@Sendable` in the stored property type.
// WHEN TO REMOVE: When closure is changed to @Sendable or compiler infers it.
// TRACKING: unsafe-audit-findings.md Category D SP-4.

/// A composable boolean test that determines whether values of type `T` satisfy a condition.
///
/// Predicates wrap evaluation closures and provide fluent APIs for building complex boolean logic.
/// Compose simple predicates with logical operators to create sophisticated validation rules.
///
/// ## Example
///
/// ```swift
/// let isEven = Predicate<Int> { $0 % 2 == 0 }
/// let isPositive = Predicate<Int> { $0 > 0 }
///
/// // Compose with operators
/// let valid = isEven && isPositive
/// valid(4)   // true
/// valid(-2)  // false
///
/// // Or use fluent methods
/// let invalid = isEven.and(isPositive).negated
///
/// // Use factory methods
/// let inRange = Predicate<Int>.in.range(1...10)
/// let hasPrefix = Predicate<String>.has.prefix("foo")
/// ```
public struct Predicate<T>: @unchecked Sendable {
    /// Closure that evaluates whether a value satisfies the condition.
    public var evaluate: (T) -> Bool

    /// Creates a predicate from an evaluation closure.
    @inlinable
    public init(_ evaluate: @escaping (T) -> Bool) {
        self.evaluate = evaluate
    }
}

// MARK: - Call as Function

extension Predicate {
    /// Tests whether the value satisfies the predicate's condition.
    @inlinable
    public static func callAsFunction(_ predicate: Predicate, _ value: T) -> Bool {
        predicate.evaluate(value)
    }

    /// Tests whether the value satisfies this predicate's condition.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// isEven(4)  // true
    /// isEven(3)  // false
    /// ```
    @inlinable
    public func callAsFunction(_ value: T) -> Bool {
        Self.callAsFunction(self, value)
    }
}

// MARK: - Constants

extension Predicate {
    /// Predicate that accepts all values.
    ///
    /// Identity element for `and` operations: `p.and(.always) ≡ p`
    @inlinable
    public static var always: Predicate {
        Predicate { _ in true }
    }

    /// Predicate that rejects all values.
    ///
    /// Identity element for `or` operations: `p.or(.never) ≡ p`
    @inlinable
    public static var never: Predicate {
        Predicate { _ in false }
    }
}

// MARK: - Negation

extension Predicate {
    /// Returns the logical inverse of the predicate.
    @inlinable
    public static func negated(_ predicate: Predicate) -> Predicate {
        Predicate { !predicate.evaluate($0) }
    }

    /// Logical inverse of this predicate.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isOdd = isEven.negated
    /// isOdd(3)  // true
    /// isOdd(4)  // false
    /// ```
    @inlinable
    public var negated: Predicate {
        Self.negated(self)
    }

    /// Returns the logical negation of the predicate.
    @inlinable
    public static prefix func ! (predicate: Predicate) -> Predicate {
        Self.negated(predicate)
    }
}

// MARK: - Conjunction (AND)

extension Predicate {
    /// Combines two predicates using logical AND.
    ///
    /// Returns `true` only when both predicates succeed. Short-circuits if the first predicate fails.
    @inlinable
    public static func and(_ lhs: Predicate, _ rhs: Predicate) -> Predicate {
        Predicate { lhs.evaluate($0) && rhs.evaluate($0) }
    }

    /// Combines this predicate with another using logical AND.
    ///
    /// Returns `true` only when both predicates succeed. Short-circuits if this predicate fails.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isPositive = Predicate<Int> { $0 > 0 }
    /// let valid = isEven.and(isPositive)
    /// valid(4)   // true
    /// valid(-4)  // false
    /// valid(3)   // false
    /// ```
    @inlinable
    public func and(_ other: Predicate) -> Predicate {
        Self.and(self, other)
    }

    /// Combines two predicates using logical AND.
    @inlinable
    public static func && (lhs: Predicate, rhs: Predicate) -> Predicate {
        Self.and(lhs, rhs)
    }
}

// MARK: - Disjunction (OR)

extension Predicate {
    /// Combines two predicates using logical OR.
    ///
    /// Returns `true` when either predicate succeeds. Short-circuits if the first predicate succeeds.
    @inlinable
    public static func or(_ lhs: Predicate, _ rhs: Predicate) -> Predicate {
        Predicate { lhs.evaluate($0) || rhs.evaluate($0) }
    }

    /// Combines this predicate with another using logical OR.
    ///
    /// Returns `true` when either predicate succeeds. Short-circuits if this predicate succeeds.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isNegative = Predicate<Int> { $0 < 0 }
    /// let valid = isEven.or(isNegative)
    /// valid(4)   // true (even)
    /// valid(-3)  // true (negative)
    /// valid(3)   // false (neither)
    /// ```
    @inlinable
    public func or(_ other: Predicate) -> Predicate {
        Self.or(self, other)
    }

    /// Combines two predicates using logical OR.
    @inlinable
    public static func || (lhs: Predicate, rhs: Predicate) -> Predicate {
        Self.or(lhs, rhs)
    }
}

// MARK: - Exclusive Or (XOR)

extension Predicate {
    /// Combines two predicates using exclusive OR.
    ///
    /// Returns `true` when exactly one predicate succeeds.
    @inlinable
    public static func xor(_ lhs: Predicate, _ rhs: Predicate) -> Predicate {
        Predicate { lhs.evaluate($0) != rhs.evaluate($0) }
    }

    /// Combines this predicate with another using exclusive OR.
    ///
    /// Returns `true` when exactly one predicate succeeds.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isPositive = Predicate<Int> { $0 > 0 }
    /// let onlyOne = isEven.xor(isPositive)
    /// onlyOne(4)   // false (both)
    /// onlyOne(3)   // true (positive only)
    /// onlyOne(-4)  // true (even only)
    /// onlyOne(-3)  // false (neither)
    /// ```
    @inlinable
    public func xor(_ other: Predicate) -> Predicate {
        Self.xor(self, other)
    }

    /// Combines two predicates using exclusive OR.
    @inlinable
    public static func ^ (lhs: Predicate, rhs: Predicate) -> Predicate {
        Self.xor(lhs, rhs)
    }
}

// MARK: - NAND / NOR

extension Predicate {
    /// Combines two predicates using NAND (not both).
    ///
    /// Returns `true` unless both predicates succeed. Equivalent to `!(lhs && rhs)`.
    @inlinable
    public static func nand(_ lhs: Predicate, _ rhs: Predicate) -> Predicate {
        Predicate { !lhs.evaluate($0) || !rhs.evaluate($0) }
    }

    /// Combines two predicates using NOR (neither).
    ///
    /// Returns `true` only when both predicates fail. Equivalent to `!(lhs || rhs)`.
    @inlinable
    public static func nor(_ lhs: Predicate, _ rhs: Predicate) -> Predicate {
        Predicate { !lhs.evaluate($0) && !rhs.evaluate($0) }
    }

    /// Combines this predicate with another using NAND (not both).
    ///
    /// Returns `true` unless both predicates succeed. Equivalent to `!(self && other)`.
    @inlinable
    public func nand(_ other: Predicate) -> Predicate {
        Self.nand(self, other)
    }

    /// Combines this predicate with another using NOR (neither).
    ///
    /// Returns `true` only when both predicates fail. Equivalent to `!(self || other)`.
    @inlinable
    public func nor(_ other: Predicate) -> Predicate {
        Self.nor(self, other)
    }
}

// MARK: - Implication

extension Predicate {
    /// Creates logical implication: if lhs, then rhs must hold.
    ///
    /// Returns `true` unless lhs succeeds and rhs fails. Equivalent to `!lhs || rhs`.
    @inlinable
    public static func implies(_ lhs: Predicate, _ rhs: Predicate) -> Predicate {
        Self.or(Self.negated(lhs), rhs)
    }

    /// Creates biconditional: both must have the same result.
    ///
    /// Returns `true` when both succeed or both fail. Equivalent to `!(lhs.xor(rhs))`.
    @inlinable
    public static func iff(_ lhs: Predicate, _ rhs: Predicate) -> Predicate {
        Self.negated(Self.xor(lhs, rhs))
    }

    /// Creates reverse implication: lhs holds unless condition is true.
    ///
    /// Reads naturally for validation rules. Equivalent to `condition.implies(lhs)`.
    @inlinable
    public static func unless(_ lhs: Predicate, condition: Predicate) -> Predicate {
        Self.implies(condition, lhs)
    }

    /// Creates logical implication: if this, then other must hold.
    ///
    /// Returns `true` unless this succeeds and other fails. Equivalent to `!self || other`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let isAdmin = Predicate<User> { $0.role == .admin }
    /// let canDelete = Predicate<User> { $0.permissions.contains(.delete) }
    /// let valid = isAdmin.implies(canDelete)
    /// // If admin, must have delete permission
    /// ```
    @inlinable
    public func implies(_ other: Predicate) -> Predicate {
        Self.implies(self, other)
    }

    /// Creates biconditional: both must have the same result.
    ///
    /// Returns `true` when both succeed or both fail. Equivalent to `!(self.xor(other))`.
    @inlinable
    public func iff(_ other: Predicate) -> Predicate {
        Self.iff(self, other)
    }

    /// Creates reverse implication: this holds unless condition is true.
    ///
    /// Reads naturally for validation rules. Equivalent to `condition.implies(self)`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let hasPayment = Predicate<User> { $0.hasPaymentMethod }
    /// let isFree = Predicate<User> { $0.tier == .free }
    /// let valid = hasPayment.unless(isFree)
    /// // Must have payment unless free tier
    /// ```
    @inlinable
    public func unless(_ condition: Predicate) -> Predicate {
        Self.unless(self, condition: condition)
    }
}

// MARK: - Contravariant Mapping

extension Predicate {
    /// Adapts a predicate to test a different type via transformation.
    ///
    /// Applies the transform first, then evaluates the predicate on the result.
    @inlinable
    public static func pullback<U>(
        _ predicate: Predicate,
        _ transform: @escaping (U) -> T
    ) -> Predicate<U> {
        Predicate<U> { predicate.evaluate(transform($0)) }
    }

    /// Adapts a predicate to test a property via key path.
    @inlinable
    public static func pullback<U>(_ predicate: Predicate, _ keyPath: KeyPath<U, T>) -> Predicate<U> {
        Self.pullback(predicate) { $0[keyPath: keyPath] }
    }

    /// Adapts this predicate to test a different type via transformation.
    ///
    /// Applies the transform first, then evaluates this predicate on the result.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let hasEvenLength = isEven.pullback(\.count)
    /// hasEvenLength("hi")    // true (count 2)
    /// hasEvenLength("hello") // false (count 5)
    /// ```
    @inlinable
    public func pullback<U>(_ transform: @escaping (U) -> T) -> Predicate<U> {
        Self.pullback(self, transform)
    }

    /// Adapts this predicate to test a property via key path.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let isLong = Predicate<Int> { $0 > 10 }
    /// let hasLongName = isLong.pullback(\User.name.count)
    /// ```
    @inlinable
    public func pullback<U>(_ keyPath: KeyPath<U, T>) -> Predicate<U> {
        Self.pullback(self, keyPath)
    }
}

// MARK: - Where Clause

extension Predicate {
    /// Creates a predicate that tests a property using another predicate.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let isAdult = Predicate<Person>.where(\.age, .greater.thanOrEqualTo(18))
    /// ```
    @inlinable
    public static func `where`<V>(_ keyPath: KeyPath<T, V>, _ predicate: Predicate<V>) -> Predicate {
        predicate.pullback(keyPath)
    }

    /// Creates a predicate that tests a property using a closure.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let hasLongName = Predicate<Person>.where(\.name) { $0.count > 10 }
    /// ```
    @inlinable
    public static func `where`<V>(
        _ keyPath: KeyPath<T, V>,
        _ test: @escaping (V) -> Bool
    ) -> Predicate {
        Predicate<V>(test).pullback(keyPath)
    }
}

// MARK: - Optional Lifting

extension Predicate {
    /// Adapts a predicate to handle optional values with a default result.
    ///
    /// Returns the default for `nil`, otherwise evaluates the wrapped value.
    @inlinable
    public static func optional(_ predicate: Predicate, default defaultValue: Bool) -> Predicate<T?> {
        Predicate<T?> { value in
            guard let value else { return defaultValue }
            return predicate.evaluate(value)
        }
    }

    /// Adapts this predicate to handle optional values with a default result.
    ///
    /// Returns the default for `nil`, otherwise evaluates the wrapped value.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let test = isEven.optional(default: false)
    /// test(4)    // true
    /// test(nil)  // false
    /// ```
    @inlinable
    public func optional(default defaultValue: Bool) -> Predicate<T?> {
        Self.optional(self, default: defaultValue)
    }
}

// MARK: - Quantifiers

extension Predicate {
    /// Creates a predicate that checks if all array elements satisfy the condition.
    @inlinable
    public static func all(_ predicate: Predicate) -> Predicate<[T]> {
        Predicate<[T]> { $0.allSatisfy(predicate.evaluate) }
    }

    /// Creates a predicate that checks if any array element satisfies the condition.
    @inlinable
    public static func any(_ predicate: Predicate) -> Predicate<[T]> {
        Predicate<[T]> { $0.contains(where: predicate.evaluate) }
    }

    /// Creates a predicate that checks if no array elements satisfy the condition.
    @inlinable
    public static func none(_ predicate: Predicate) -> Predicate<[T]> {
        Predicate<[T]> { !$0.contains(where: predicate.evaluate) }
    }

    /// Creates predicate that checks if all sequence elements satisfy the condition.
    @inlinable
    public static func forAll<S: Sequence>(_ predicate: Predicate) -> Predicate<S>
    where S.Element == T {
        Predicate<S> { $0.allSatisfy(predicate.evaluate) }
    }

    /// Creates predicate that checks if any sequence element satisfies the condition.
    @inlinable
    public static func forAny<S: Sequence>(_ predicate: Predicate) -> Predicate<S>
    where S.Element == T {
        Predicate<S> { $0.contains(where: predicate.evaluate) }
    }

    /// Creates predicate that checks if no sequence elements satisfy the condition.
    @inlinable
    public static func forNone<S: Sequence>(_ predicate: Predicate) -> Predicate<S>
    where S.Element == T {
        Predicate<S> { !$0.contains(where: predicate.evaluate) }
    }

    /// Predicate that checks if all array elements satisfy this condition.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let allEven = isEven.all
    /// allEven([2, 4, 6])  // true
    /// allEven([2, 3, 4])  // false
    /// ```
    @inlinable
    public var all: Predicate<[T]> {
        Self.all(self)
    }

    /// Predicate that checks if any array element satisfies this condition.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let anyEven = isEven.any
    /// anyEven([1, 2, 3])  // true
    /// anyEven([1, 3, 5])  // false
    /// ```
    @inlinable
    public var any: Predicate<[T]> {
        Self.any(self)
    }

    /// Predicate that checks if no array elements satisfy this condition.
    @inlinable
    public var none: Predicate<[T]> {
        Self.none(self)
    }

    /// Creates predicate that checks if all sequence elements satisfy this condition.
    @inlinable
    public func forAll<S: Sequence>() -> Predicate<S> where S.Element == T {
        Self.forAll(self)
    }

    /// Creates predicate that checks if any sequence element satisfies this condition.
    @inlinable
    public func forAny<S: Sequence>() -> Predicate<S> where S.Element == T {
        Self.forAny(self)
    }

    /// Creates predicate that checks if no sequence elements satisfy this condition.
    @inlinable
    public func forNone<S: Sequence>() -> Predicate<S> where S.Element == T {
        Self.forNone(self)
    }
}
