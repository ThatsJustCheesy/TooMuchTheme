import XCTest
@testable import TooMuchTheme

final class ScopeSelectorMatchTests: XCTestCase {
    
    func testPath() throws {
        for (selector, context, shouldMatch) in [
            ("a", Context(main: Scope("a")), true),
            ("a", Context(main: Scope("a.something")), true),
            ("a", Context(main: Scope("")), false),
            (" ab ", Context(main: Scope("ab")), true),
            (" ab ", Context(main: Scope("a.ab")), false),
            ("a b cd", Context(main: Scope("first second a b cd last")), true),
            ("a b cd", Context(main: Scope("a b b something.else cd ef")), true),
            ("a b cd", Context(main: Scope("a something.else b ef")), false),
            (" a > b cd>e ", Context(main: Scope("a b other things cd.e e.f")), true),
            (" a > b cd>e ", Context(main: Scope("a other things b cd e")), false),
            (" a > b cd>e ", Context(main: Scope("a b other things cd.e f.e e")), false),
            ("*.a b.*.c.*", Context(main: Scope("b.a b.d.c.e")), true),
            ("*.a b.*.c.*", Context(main: Scope("b.a b.c")), false),
            ("*.a b.*.c.*", Context(main: Scope("a b.d.c.e")), false),
            ("*", Context(main: Scope("")), false),
            ("", Context(main: Scope("something")), true),
            ("", Context(main: Scope("")), true)
        ] {
            try assert(selector: selector, context: context, shouldMatch: shouldMatch)
        }
    }
    
    func testGroup() throws {
        for (selector, context, shouldMatch) in [
            ("(first second.subsecond)", Context(main: Scope("first.a b.c second.subsecond.d.efg")), true),
            ("(first second.subsecond)", Context(main: Scope("first.a b.c second second.subsecond.d.efg")), true),
            ("(first second.subsecond)", Context(main: Scope("first.a b.c second.d.efg")), false)
        ] {
            try assert(selector: selector, context: context, shouldMatch: shouldMatch)
        }
    }
    
    func testFilter() throws {
        for (selector, context, shouldMatch) in [
            ("L: a", Context(left: Scope("a"), main: Scope("random stuff")), true),
            ("L: a", Context(left: Scope("random stuff"), main: Scope("a")), false),
            ("R: a", Context(left: Scope("random stuff"), main: Scope("a")), true),
            ("R: a", Context(left: Scope("a"), main: Scope("random stuff")), false),
            ("B: a", Context(left: Scope("front a back"), main: Scope("a.bcd")), true),
            ("B: a", Context(left: Scope("random stuff"), main: Scope("a")), false),
            ("B: a", Context(left: Scope("a"), main: Scope("random stuff")), false)
        ] {
            try assert(selector: selector, context: context, shouldMatch: shouldMatch)
        }
    }
    
    func testExpression() throws {
        for (selector, context, shouldMatch) in [
            ("- a b", Context(main: Scope("random stuff")), true),
            ("- a b", Context(main: Scope("a stuff")), true),
            ("- a b", Context(main: Scope("random a stuff b.back")), false)
        ] {
            try assert(selector: selector, context: context, shouldMatch: shouldMatch)
        }
    }
    
    func testComposite() throws {
        for (selector, context, shouldMatch) in [
            ("a | b", Context(main: Scope("a")), true),
            ("a | b", Context(main: Scope("a b.c")), true),
            ("a | b", Context(main: Scope("b c")), true),
            ("a | b", Context(main: Scope("c")), false),
            ("a & b", Context(main: Scope("a.front b.back")), true),
            ("a & b", Context(main: Scope("b a c")), true),
            ("a & b", Context(main: Scope("a.b")), false),
            ("a & b", Context(main: Scope("b.a b")), false),
            ("- a b - c", Context(main: Scope("random a stuff.c back.b")), true),
            ("- a b - c", Context(main: Scope("random a stuff.c b.back")), false),
            ("- a b - c", Context(main: Scope("random b a stuff.c")), true),
            ("- a b - c", Context(main: Scope("random b a c stuff")), false)
        ] {
            try assert(selector: selector, context: context, shouldMatch: shouldMatch)
        }
    }
    
    func testSelector() throws {
        for (selector, context, shouldMatch) in [
            ("a, b", Context(main: Scope("a")), true),
            ("a, b", Context(main: Scope("b.c.def")), true),
            ("a, b", Context(main: Scope("c.a c.b")), false)
        ] {
            try assert(selector: selector, context: context, shouldMatch: shouldMatch)
        }
    }
    
}

private func assert(selector: String, context: Context, shouldMatch: Bool) throws {
    let selector = try ScopeSelector(selector)
    let message = "\(selector) should\(shouldMatch ? "" : " not") match \(context)"
    if shouldMatch {
        XCTAssertTrue(selector.matches(context), message)
    } else {
        XCTAssertFalse(selector.matches(context), message)
    }
}
