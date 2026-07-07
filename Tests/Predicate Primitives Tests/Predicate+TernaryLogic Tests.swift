// Predicate+TernaryLogic Tests.swift
// Tests for three-valued logic lifting with optional values.

import Logic_Ternary_Primitives
import Testing

@testable import Predicate_Primitives

// MARK: - Basic Ternary Logic Tests

@Suite
struct `Ternary Logic Basic Tests` {
    let isEven = Predicate<Int> { $0 % 2 == 0 }
    let isPositive = Predicate<Int> { $0 > 0 }

    @Test(arguments: [
        (value: 4 as Int?, expected: true),
        (value: 3 as Int?, expected: false),
        (value: nil as Int?, expected: nil as Bool?),
    ])
    func `static call as function`(value: Int?, expected: Bool?) {
        let result: Bool? = Predicate.callAsFunction(isEven, value)
        #expect(result == expected)
    }

    @Test(arguments: [
        (value: 4 as Int?, expected: true),
        (value: 3 as Int?, expected: false),
        (value: nil as Int?, expected: nil as Bool?),
    ])
    func `instance call as function`(value: Int?, expected: Bool?) {
        let result: Bool? = isEven(value)
        #expect(result == expected)
    }

    @Test
    func `returns unknown for nil`() {
        let result: Bool? = isEven(nil)
        #expect(result == nil)
    }

    @Test
    func `returns true for matching value`() {
        let result: Bool? = isEven(4)
        #expect(result == true)
    }

    @Test
    func `returns false for non matching value`() {
        let result: Bool? = isEven(3)
        #expect(result == false)
    }
}

// MARK: - Strong Kleene Semantics Tests

@Suite
struct `Strong Kleene Semantics Tests` {
    let isEven = Predicate<Int> { $0 % 2 == 0 }
    let isPositive = Predicate<Int> { $0 > 0 }

    @Test(arguments: [
        // AND truth table with unknown
        (lhs: nil as Int?, rhs: 4 as Int?, op: "&&", expected: nil as Bool?),  // unknown && true = unknown
        (lhs: nil as Int?, rhs: 3 as Int?, op: "&&", expected: nil as Bool?),  // unknown && false = unknown
        (lhs: 4 as Int?, rhs: nil as Int?, op: "&&", expected: nil as Bool?),  // true && unknown = unknown
        (lhs: 3 as Int?, rhs: nil as Int?, op: "&&", expected: false as Bool?),  // false && unknown = false
    ])
    func `ternary AND semantics`(lhs: Int?, rhs: Int?, op: String, expected: Bool?) {
        let lhsResult: Bool? = isEven(lhs)
        let rhsResult: Bool? = isPositive(rhs)
        let result = lhsResult && rhsResult
        #expect(result == expected)
    }

    @Test(arguments: [
        // OR truth table with unknown (Strong Kleene semantics)
        // isEven: even numbers, isPositive: > 0
        (lhs: nil as Int?, rhs: 4 as Int?, op: "||", expected: true as Bool?),  // unknown || true = true
        (lhs: nil as Int?, rhs: -3 as Int?, op: "||", expected: nil as Bool?),  // unknown || false = unknown
        (lhs: 4 as Int?, rhs: nil as Int?, op: "||", expected: true as Bool?),  // true || unknown = true
        (lhs: 3 as Int?, rhs: nil as Int?, op: "||", expected: nil as Bool?),  // false || unknown = unknown
    ])
    func `ternary OR semantics`(lhs: Int?, rhs: Int?, op: String, expected: Bool?) {
        let lhsResult: Bool? = isEven(lhs)
        let rhsResult: Bool? = isPositive(rhs)
        let result = lhsResult || rhsResult
        #expect(result == expected)
    }
}

// MARK: - Composition with Optional Values

@Suite
struct `Optional Composition Tests` {
    let isEven = Predicate<Int> { $0 % 2 == 0 }
    let isPositive = Predicate<Int> { $0 > 0 }

    @Test
    func `compose with AND operator`() {
        let combined = isEven && isPositive

        let result1: Bool? = combined(4)
        #expect(result1 == true)

        let result2: Bool? = combined(nil)
        #expect(result2 == nil)
    }

    @Test
    func `compose with OR operator`() {
        let combined = isEven || isPositive

        let result1: Bool? = combined(3)
        #expect(result1 == true)

        let result2: Bool? = combined(nil)
        #expect(result2 == nil)
    }

    @Test
    func `compose with NOT operator`() {
        let isOdd = !isEven

        let result1: Bool? = isOdd(3)
        #expect(result1 == true)

        let result2: Bool? = isOdd(nil)
        #expect(result2 == nil)
    }

    @Test
    func `compose with XOR operator`() {
        let combined = isEven ^ isPositive

        let result1: Bool? = combined(3)
        #expect(result1 == true)

        let result2: Bool? = combined(nil)
        #expect(result2 == nil)
    }
}

// MARK: - Type Inference Tests

@Suite
struct `Ternary Logic Type Inference Tests` {
    let isEven = Predicate<Int> { $0 % 2 == 0 }

    @Test
    func `infers bool optional`() {
        let value: Int? = 4
        let result: Bool? = isEven(value)
        #expect(result == true)
    }

    @Test
    func `can explicitly specify type`() {
        let value: Int? = nil
        let result: Bool? = Predicate.callAsFunction(isEven, value)
        #expect(result == nil)
    }

    @Test
    func `works with chained optionals`() {
        let getValue: () -> Int? = { 4 }
        let result: Bool? = isEven(getValue())
        #expect(result == true)
    }
}

// MARK: - Integration with Fluent Methods

@Suite
struct `Ternary Logic Fluent Method Tests` {
    let isEven = Predicate<Int> { $0 % 2 == 0 }
    let isPositive = Predicate<Int> { $0 > 0 }

    @Test
    func `fluent AND with optional`() {
        let combined = isEven.and(isPositive)

        let result1: Bool? = combined(4)
        #expect(result1 == true)

        let result2: Bool? = combined(nil)
        #expect(result2 == nil)
    }

    @Test
    func `fluent OR with optional`() {
        let combined = isEven.or(isPositive)

        let result1: Bool? = combined(3)
        #expect(result1 == true)

        let result2: Bool? = combined(nil)
        #expect(result2 == nil)
    }

    @Test
    func `fluent negated with optional`() {
        let isOdd = isEven.negated

        let result1: Bool? = isOdd(3)
        #expect(result1 == true)

        let result2: Bool? = isOdd(nil)
        #expect(result2 == nil)
    }
}

// MARK: - Edge Cases

@Suite
struct `Ternary Logic Edge Cases Tests` {
    let alwaysTrue = Predicate<Int>.always
    let alwaysFalse = Predicate<Int>.never

    @Test
    func `always true with nil`() {
        let result: Bool? = alwaysTrue(nil)
        #expect(result == nil)
    }

    @Test
    func `always false with nil`() {
        let result: Bool? = alwaysFalse(nil)
        #expect(result == nil)
    }

    @Test
    func `complex predicate with nil`() {
        let isEven = Predicate<Int> { $0 % 2 == 0 }
        let isPositive = Predicate<Int> { $0 > 0 }
        let isSmall = Predicate<Int> { abs($0) < 10 }

        let complex = (isEven && isPositive) || isSmall

        let result: Bool? = complex(nil)
        #expect(result == nil)
    }

    @Test
    func `null propagation through chain`() {
        let isEven = Predicate<Int> { $0 % 2 == 0 }
        let isPositive = Predicate<Int> { $0 > 0 }
        let isSmall = Predicate<Int> { abs($0) < 10 }

        let chain = isEven.and(isPositive).or(isSmall)

        let result: Bool? = chain(nil)
        #expect(result == nil)
    }
}

// MARK: - Practical Usage Examples

@Suite
struct `Ternary Logic Practical Tests` {
    struct User {
        var age: Int?
        var isActive: Bool
    }

    @Test
    func `optional property validation`() {
        let isAdult = Predicate<Int> { $0 >= 18 }

        let user1 = User(age: 25, isActive: true)
        let user2 = User(age: 15, isActive: true)
        let user3 = User(age: nil, isActive: true)

        let result1: Bool? = isAdult(user1.age)
        #expect(result1 == true)

        let result2: Bool? = isAdult(user2.age)
        #expect(result2 == false)

        let result3: Bool? = isAdult(user3.age)
        #expect(result3 == nil)
    }

    @Test
    func `optional chain validation`() {
        struct Person {
            var name: String?
        }

        let hasLongName = Predicate<Int> { $0 > 5 }

        let person1 = Person(name: "Alexander")
        let person2 = Person(name: "Bob")
        let person3 = Person(name: nil)

        let result1: Bool? = hasLongName(person1.name?.count)
        #expect(result1 == true)

        let result2: Bool? = hasLongName(person2.name?.count)
        #expect(result2 == false)

        let result3: Bool? = hasLongName(person3.name?.count)
        #expect(result3 == nil)
    }
}

// MARK: - Comparison with Optional Lifting

@Suite
struct `Ternary Logic Vs Optional Lifting Tests` {
    let isEven = Predicate<Int> { $0 % 2 == 0 }

    @Test
    func `ternary logic returns nil`() {
        let result: Bool? = isEven(nil as Int?)
        #expect(result == nil)
    }

    @Test
    func `optional lifting with default returns false`() {
        let lifted = isEven.optional(default: false)
        let result = lifted(nil)
        #expect(result == false)
    }

    @Test
    func `optional lifting with default returns true`() {
        let lifted = isEven.optional(default: true)
        let result = lifted(nil)
        #expect(result == true)
    }

    @Test
    func `both approaches agree on non nil values`() {
        let lifted = isEven.optional(default: false)

        let ternaryResult: Bool? = isEven(4 as Int?)
        let liftedResult = lifted(4)

        #expect(ternaryResult == liftedResult)
    }
}
