import FootlessParser

// See https://macromates.com/textmate/manual/references

public struct ScopeSelector: Matcher, Parsable, CustomStringConvertible, Equatable, Codable {
    
    public struct Composite: Matcher, Parsable, CustomStringConvertible, Equatable {
        
        public var base: Expression
        public var compositions: [Composition] = []
        
        public init(base: Expression, compositions: [Composition] = []) {
            self.base = base
            self.compositions = compositions
        }
        
        func matches(_ context: Context) -> Bool {
            var match = base.matches(context)
            for composition in compositions {
                switch composition.operation {
                case .union:
                    match = match || composition.operand.matches(context)
                case .intersection:
                    match = match && composition.operand.matches(context)
                case .difference:
                    match = match && !composition.operand.matches(context)
                }
            }
            return match
        }
        
        static let parser: Parser<Character, Self> =
            curry { Composite(base: $0, compositions: $1) } <^>
                (zeroOrMore(whitespacesOrNewline) *> Expression.parser)
                <*> zeroOrMore(Composition.parser)
        
        public var description: String {
            "\(([base] + compositions).map { "\($0)" }.joined(separator: " "))"
        }
        
        public struct Composition: Parsable, CustomStringConvertible, Equatable {
            
            public var operation: Operation
            public var operand: Expression
            
            public init(operation: Operation, operand: Expression) {
                self.operation = operation
                self.operand = operand
            }
            
            public enum Operation: String, Parsable, CustomStringConvertible {
                
                case union = "|"
                case intersection = "&"
                case difference = "-"
                
                static let parser: Parser<Character, Self> =
                    { _ in Operation.union } <^> token("|") <|>
                    { _ in Operation.intersection } <^> token("&") <|>
                    { _ in Operation.difference } <^> token("-")
                
                public var description: String {
                    rawValue
                }
                
            }
            
            static let parser: Parser<Character, Self> =
                curry(Composition.init) <^>
                    (zeroOrMore(whitespacesOrNewline) *> Operation.parser) <*> Expression.parser
            
            public var description: String {
                "\(operation.rawValue) \(operand)"
            }
            
        }
        
    }
    
    public struct Expression: Matcher, Parsable, CustomStringConvertible, Equatable {
        
        public var complement: Bool = false
        public var term: Term
        
        public init(complement: Bool = false, term: Term) {
            self.complement = complement
            self.term = term
        }
        
        public enum Term: Matcher, Parsable, CustomStringConvertible, Equatable {
            
            case filter(Filter)
            case group(Group)
            case path(Path)
            
            func matches(_ context: Context) -> Bool {
                switch self {
                case let .filter(term as Matcher),
                     let .group(term as Matcher),
                     let .path(term as Matcher):
                    return term.matches(context)
                }
            }
            
            static let parser: Parser<Character, Self> =
                Term.filter <^> Filter.parser <|>
                Term.group <^> Group.parser <|>
                Term.path <^> Path.parser
            
            public var description: String {
                switch self {
                case let .filter(term as Any),
                     let .group(term as Any),
                     let .path(term as Any):
                    return "\(term)"
                }
            }
            
        }
        
        func matches(_ context: Context) -> Bool {
            (complement ? (!) : { $0 })(term.matches(context))
        }
        
        static let parser: Parser<Character, Self> =
            curry(Expression.init) <^>
                (zeroOrMore(whitespacesOrNewline) *> (token("-") *> pure(true) <|> pure(false)))
                <*> Term.parser
        
        public var description: String {
            "\(complement ? "- " : "")\(term)"
        }
        
    }
    
    public struct Filter: Matcher, Parsable, CustomStringConvertible, Equatable {
        
        public var side: Side
        public var term: Term
        
        public init(side: Side, term: Term) {
            self.side = side
            self.term = term
        }
        
        public enum Side: String, Parsable, CustomStringConvertible, Equatable {
            
            /// The left side of the cursor.
            case left = "L:"
            /// The right side of the cursor.
            case right = "R:"
            /// Both sides of the cursor.
            case both = "B:"
            
            static let parser: Parser<Character, Self> =
                (
                    { _ in Side.left } <^> token("L") <|>
                    { _ in Side.right } <^> token("R") <|>
                    { _ in Side.both } <^> token("B")
                )
                    <* token(":")
            
            public var description: String {
                rawValue
            }
            
        }
        
        public enum Term: Matcher, Parsable, CustomStringConvertible, Equatable {
            
            case group(Group)
            case path(Path)
            
            func matches(_ context: Context) -> Bool {
                switch self {
                case let .group(term as Matcher),
                     let .path(term as Matcher):
                    return term.matches(context)
                }
            }
            
            static let parser: Parser<Character, Self> =
                Term.group <^> Group.parser <|>
                Term.path <^> Path.parser
            
            public var description: String {
                switch self {
                case let .group(term as Any),
                     let .path(term as Any):
                    return "\(term)"
                }
            }
            
        }
        
        func matches(_ context: Context) -> Bool {
            let leftContext = Context(main: context.left ?? context.main)
            let rightContext = Context(main: context.main)
            switch side {
            case .left:
                return term.matches(leftContext)
            case .right:
                return term.matches(rightContext)
            case .both:
                return term.matches(leftContext) && term.matches(rightContext)
            }
        }
        
        static let parser: Parser<Character, Self> =
            curry(Filter.init) <^>
                (zeroOrMore(whitespacesOrNewline) *> Side.parser) <*> Term.parser
        
        public var description: String {
            "\(side.rawValue) \(term)"
        }
        
    }
    
    public struct Group: Matcher, Parsable, CustomStringConvertible, Equatable {
        
        public var selector: ScopeSelector
        
        public init(selector: ScopeSelector) {
            self.selector = selector
        }
        
        func matches(_ context: Context) -> Bool {
            selector.matches(context)
        }
        
        static let parser: Parser<Character, Self> =
            Group.init <^> (zeroOrMore(whitespacesOrNewline) *> token("(") *> lazy(ScopeSelector.parser) <* zeroOrMore(whitespacesOrNewline) <* token(")"))
        
        public var description: String {
            "(\(selector))"
        }
        
    }
    
    public struct Path: Matcher, Parsable, CustomStringConvertible, Equatable {
        
        public var beginAnchor: Bool = false
        public var endAnchor: Bool = false
        
        public var root: ScopeName
        public var descendents: [Descendent] = []
        
        public init(beginAnchor: Bool = false, endAnchor: Bool = false, root: ScopeName, descendents: [Descendent] = []) {
            self.beginAnchor = beginAnchor
            self.endAnchor = endAnchor
            self.root = root
            self.descendents = descendents
        }
        
        func matches(_ context: Context) -> Bool {
            var scope = context.main
            
            for descendent in [Descendent(selector: beginAnchor ? .direct : .transitive, scopeName: root)] + descendents {
                let scopeName = descendent.scopeName
                
                switch descendent.selector {
                case .transitive:
                    guard scope.matchAndRemoveLeading(scopeName) else {
                        return false
                    }
                case .direct:
                    guard scope.matchAndRemoveFirst(scopeName) else {
                        return false
                    }
                }
            }
            
            return !endAnchor || scope.isEmpty
        }
        
        static let parser: Parser<Character, Self> =
            curry { Path(beginAnchor: $0, endAnchor: $3, root: $1, descendents: $2) } <^>
                (zeroOrMore(whitespacesOrNewline) *> (token("^") *> pure(true) <|> pure(false)))
                <*> (zeroOrMore(whitespacesOrNewline) *> ScopeName.parser)
                <*> zeroOrMore(Descendent.parser)
                <*> (zeroOrMore(whitespacesOrNewline) *> (token("$") *> pure(true) <|> pure(false)))
        
        public var description: String {
            "\(beginAnchor ? "^ " : "")\(([root] + descendents).map { "\($0)" }.joined(separator: " "))\(endAnchor ? " $" : "")"
        }
        
        public struct Descendent: Parsable, CustomStringConvertible, Equatable {
            
            public var selector: Selector
            public var scopeName: ScopeName
            
            public init(selector: Selector, scopeName: ScopeName) {
                self.selector = selector
                self.scopeName = scopeName
            }
            
            public enum Selector: String, Parsable, CustomStringConvertible {
                
                case transitive = ""
                case direct = ">"
                
                static let parser: Parser<Character, Self> =
                    { _ in Selector.direct } <^> token(">") <|>
                    { _ in Selector.transitive } <^> pure("")
                
                public var description: String {
                    rawValue
                }
                
            }
            
            static let parser: Parser<Character, Self> =
                curry(Descendent.init) <^> (zeroOrMore(whitespacesOrNewline) *> Selector.parser) <*> (zeroOrMore(whitespacesOrNewline) *> ScopeName.parser)
            
            public var description: String {
                switch selector {
                case .transitive:
                    return "\(scopeName)"
                default:
                    return "\(selector) \(scopeName)"
                }
            }
            
        }
        
    }
    
    public var composites: [Composite] = []
    
    public init(composites: [Composite]) {
        self.composites = composites
    }
    
    public func matches(_ context: Context) -> Bool {
        composites.isEmpty || composites.first { $0.matches(context) } != nil
    }
    
    static let parser: Parser<Character, Self> =
        ScopeSelector.init <^> (
            (extend <^> Composite.parser <*> zeroOrMore(zeroOrMore(whitespacesOrNewline) *> token(",") *> Composite.parser))
            <|> pure([])
        )
    
    public var description: String {
        composites.map { "\($0)" }.joined(separator: ", ")
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

protocol Parsable {
    
    static var parser: Parser<Character, Self> { get }
    
}

extension Parsable {
    
    public init(_ string: String) throws {
        self = try parse(Self.parser, string)
    }
    
}

private protocol Matcher {
    
    func matches(_ context: Context) -> Bool
    
}
