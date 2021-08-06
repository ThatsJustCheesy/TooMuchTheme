
public struct Context {
    
    public var left: Scope?
    public var main: Scope
    
    public init(left: Scope? = nil, main: Scope) {
        self.left = left
        self.main = main
    }
    
}
