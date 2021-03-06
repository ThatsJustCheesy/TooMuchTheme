import XCTest
@testable import TooMuchTheme

final class ScopeSelectorParseTests: XCTestCase {
    
    func testPath() throws {
        for (selector, expected) in [
            ("a", ScopeSelector(composites: [.init(base: .init(term: .path(.init(root: "a", descendents: []))))])),
            (" ab ", ScopeSelector(composites: [.init(base: .init(term: .path(.init(root: "ab", descendents: []))))])),
            ("a b cd", ScopeSelector(composites: [.init(base: .init(term: .path(.init(root: "a", descendents: [.init(selector: .transitive, scopeName: "b"), .init(selector: .transitive, scopeName: "cd")]))))])),
            (" a > b cd>e ", ScopeSelector(composites: [.init(base: .init(term: .path(.init(root: "a", descendents: [.init(selector: .direct, scopeName: "b"), .init(selector: .transitive, scopeName: "cd"), .init(selector: .direct, scopeName: "e")]))))]))
        ] {
            XCTAssertEqual(try ScopeSelector(selector), expected)
        }
    }
    
    func testGroup() throws {
        for (selector, expected) in [
            ("(first second)", ScopeSelector(composites: [.init(base: .init(term: .group(.init(selector: .init(composites: [.init(base: .init(term: .path(.init(root: "first", descendents: [.init(selector: .transitive, scopeName: "second")]))))])))))]))
        ] {
            XCTAssertEqual(try ScopeSelector(selector), expected)
        }
    }
    
    func testFilter() throws {
        for (selector, expected) in [
            ("L: a", ScopeSelector(composites: [.init(base: .init(term: .filter(.init(side: .left, term: .path(.init(root: "a"))))))])),
            ("R: a", ScopeSelector(composites: [.init(base: .init(term: .filter(.init(side: .right, term: .path(.init(root: "a"))))))])),
            ("B: a", ScopeSelector(composites: [.init(base: .init(term: .filter(.init(side: .both, term: .path(.init(root: "a"))))))])),
            ("L: (a)", ScopeSelector(composites: [.init(base: .init(term: .filter(.init(side: .left, term: .group(.init(selector: .init(composites: [.init(base: .init(term: .path(.init(root: "a"))))])))))))])),
        ] {
            XCTAssertEqual(try ScopeSelector(selector), expected)
        }
    }
    
    func testExpression() throws {
        for (selector, expected) in [
            ("- a b", ScopeSelector(composites: [.init(base: .init(complement: true, term: .path(.init(root: "a", descendents: [.init(selector: .transitive, scopeName: "b")]))))]))
        ] {
            XCTAssertEqual(try ScopeSelector(selector), expected)
        }
    }
    
    func testComposite() throws {
        for (selector, expected) in [
            ("a | b", ScopeSelector(composites: [.init(base: .init(term: .path(.init(root: "a"))), compositions: [.init(operation: .union, operand: .init(term: .path(.init(root: "b"))))])])),
            ("a & b", ScopeSelector(composites: [.init(base: .init(term: .path(.init(root: "a"))), compositions: [.init(operation: .intersection, operand: .init(term: .path(.init(root: "b"))))])])),
            ("- a b - c", ScopeSelector(composites: [.init(base: .init(complement: true, term: .path(.init(root: "a", descendents: [.init(selector: .transitive, scopeName: "b")]))), compositions: [.init(operation: .difference, operand: .init(term: .path(.init(root: "c"))))])]))
        ] {
            XCTAssertEqual(try ScopeSelector(selector), expected)
        }
    }
    
    func testSelector() throws {
        for (selector, expected) in [
            ("a, b", ScopeSelector(composites: [.init(base: .init(term: .path(.init(root: "a")))), .init(base: .init(term: .path(.init(root: "b"))))]))
        ] {
            XCTAssertEqual(try ScopeSelector(selector), expected)
        }
    }
    
    // Newlines appear in some scope selectors, and hyphens apprear in
    // some scope names, like those found in the Brilliance TextMate themes.
    func testNewlineInSelectorAndPunctuationInScopeName() throws {
        for (selector, expected) in [
            (
                "meta.property.vendor.microsoft.trident.5,\nmeta.property.vendor.microsoft.trident.5 support.type.property-name",
                ScopeSelector(composites: [
                    .init(base: .init(term: .path(.init(root: "meta.property.vendor.microsoft.trident.5")))),
                    .init(base: .init(term: .path(.init(root: "meta.property.vendor.microsoft.trident.5", descendents: [
                        .init(selector: .transitive, scopeName: "support.type.property-name")
                    ]))))
                ])
            ),
            (
                "under_score.underscore_",
                ScopeSelector(composites: [.init(base: .init(term: .path(.init(root: "under_score.underscore_"))))])
            ),
            (
                "star.* *.star",
                ScopeSelector(composites: [.init(base: .init(term: .path(.init(root: "star.*", descendents: [
                    .init(selector: .transitive, scopeName: "*.star")
                ]))))])
            )
        ] {
            XCTAssertEqual(try ScopeSelector(selector), expected)
        }
    }
    
}
