extension Predicate {
    /// Namespace for predicates that test pattern matching.
    public struct Matches {
        @usableFromInline
        init() {}
    }

    /// Access point for `matches`-style predicates like `.matches.regex(...)`.
    public static var matches: Matches.Type { Matches.self }
}

extension Predicate.Matches where T: StringProtocol {
    /// Tests whether the entire string matches the regex.
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    @inlinable
    public static func regex(_ regex: Regex<Substring>) -> Predicate<T> {
        // swiftlint:disable:next no_try_optional - reason: a regex evaluation error means no-match; the predicate's Bool verdict is the entire signal, so nil-on-error is the intended semantics ([IMPL-108] escape hatch)
        Predicate { (try? regex.wholeMatch(in: String($0))) != nil }
    }
}
