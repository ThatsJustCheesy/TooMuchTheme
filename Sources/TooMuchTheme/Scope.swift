
public struct Scope: Equatable, Codable {
    
    public var elements: [ScopeName]
    
    public init(_ elements: [ScopeName]) {
        self.elements = elements
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

extension Scope: CustomStringConvertible, ExpressibleByStringLiteral {
    
    public init<Str: StringProtocol>(_ string: Str) throws {
        try self.init(string.split { $0.isWhitespace }.map { try ScopeName(String($0)) })
    }
    
    public init(stringLiteral value: StringLiteralType) {
        try! self.init(value)
    }
    
    public var description: String {
        elements.map { $0.description }.joined(separator: " ")
    }
    
}

extension Scope {
    
    public mutating func matchAndRemoveFirst(_ name: ScopeName) -> Bool {
        elements.popFirst()?.isRefinement(of: name) ?? false
    }
    
    public mutating func matchAndRemoveLeading(_ name: ScopeName) -> Bool {
        var elements = self.elements
        while let first = elements.popFirst() {
            if first.isRefinement(of: name) {
                self.elements = elements
                return true
            }
        }
        return false
    }
    
    public var isEmpty: Bool {
        elements.isEmpty
    }
    
}

extension Array {
    
    fileprivate mutating func popFirst() -> Element? {
        guard !isEmpty else {
            return nil
        }
        return removeFirst()
    }
    
}
