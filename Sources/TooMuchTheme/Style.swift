import Foundation.NSAttributedString

public struct Style: Codable {
    
    public var name: String?
    public var scope: ScopeSelector?
    public var settings: [String : String]
    
}

extension Style {
    
    public func attributes(fontProvider: FontProvider) throws -> [AttributedString.Key : Any] {
        var attributes: [AttributedString.Key : Any] = [:]
        for (key, value) in settings {
            switch key {
            case "background":
                attributes[.backgroundColor] = try Color(hex: value)
            case "foreground":
                attributes[.foregroundColor] = try Color(hex: value)
            case "fontStyle":
                if value.contains("underline") {
                    attributes[.underlineStyle] = UnderlineStyle.single.rawValue as NSNumber
                } else {
                    attributes.removeValue(forKey: .underlineStyle)
                }
                attributes[.font] = fontProvider.provideFont(bold: value.contains("bold"), italic: value.contains("italic"))
            default:
                break
            }
        }
        if attributes[.font] == nil {
            attributes[.font] = fontProvider.provideFont(bold: false, italic: false)
        }
        return attributes
    }
    
}
