import Foundation.NSAttributedString

public struct Theme: Codable {
    
    public typealias Metadata = [MetadataKey : String]
    
    public var metadata: Metadata
    
    public enum MetadataKey: String, CaseIterable {
        
        case uuid
        case semanticClass
        case name
        case author
        case comment
        
    }
    
    public var styles: [Style]
    
    public init(metadata: Metadata, styles: [Style]) {
        self.metadata = metadata
        self.styles = styles
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            metadata: Metadata(uniqueKeysWithValues:
                MetadataKey.allCases
                    .compactMap { key in
                        (try? container.decode(String.self, forKey: CodingKeys(rawValue: key.rawValue)!)).map {
                            (key: key, value: $0)
                        }
                    }
            ),
            styles: try container.decode([Style].self, forKey: .settings)
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        for (key, value) in metadata {
            try container.encode(value, forKey: CodingKeys(rawValue: key.rawValue)!)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case uuid
        case semanticClass
        case name
        case author
        case comment
        
        case settings
        
    }
    
}

extension Theme {
    
    public func attributes(for context: Context, fontProvider: FontProvider) throws -> [AttributedString.Key : Any] {
        var attributes: [AttributedString.Key : Any] = [:]
        for style in styles {
            if style.scope?.matches(context) ?? true {
                attributes.merge(try style.attributes(fontProvider: fontProvider), uniquingKeysWith: { $1 })
            }
        }
        return attributes
    }
    
    public func attributes(for scope: Scope, fontProvider: FontProvider) throws -> [AttributedString.Key : Any] {
        try attributes(for: Context(main: scope), fontProvider: fontProvider)
    }
    
}
