import Foundation
import FootlessParser

public struct ScopeName: Equatable, Codable {
    
    public var components: [String]
    
    public init(_ components: [String]) {
        self.components = components
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(container.decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
    
}

extension ScopeName: Parsable, LosslessStringConvertible, ExpressibleByStringLiteral {
    
    static var parser: Parser<Character, Self> {
        let componentFirstCharacter = CharacterSet.alphanumerics.union(["_"])
        let componentSubsequentCharacter = componentFirstCharacter.union(["-"])
        let component = extend <^> (token("*") <|> char(componentFirstCharacter, name: "scope name character"))
            <*> zeroOrMore(token("*") <|> char(componentSubsequentCharacter, name: "scope name character"))
        return ScopeName.init <^> (extend <^> component <*> zeroOrMore(token(".") *> component))
    }
    
    public init<Str: StringProtocol>(_ string: Str) {
        self.init(string.split(separator: ".").map { String($0) })
    }
    
    public var description: String {
        components.joined(separator: ".")
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
    
}

extension ScopeName {
    
    public func isPrefix(of name: ScopeName) -> Bool {
        components.count <= name.components.count &&
            zip(components, name.components).allSatisfy { $0 == $1 || $0 == "*" }
    }
    
    public func isRefinement(of name: ScopeName) -> Bool {
        name.isPrefix(of: self)
    }
    
    public mutating func removeFirst(_ count: Int = 1) {
        components.removeFirst(count)
    }
    
    public mutating func removePrefix(_ name: ScopeName) -> Bool {
        guard isRefinement(of: name) else {
            return false
        }
        removeFirst(name.components.count)
        return true
    }
    
    public var isEmpty: Bool {
        components.isEmpty
    }
    
}
