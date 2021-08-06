
#if canImport(AppKit)

import AppKit
public typealias AttributedString = NSAttributedString
public typealias UnderlineStyle = NSUnderlineStyle

#elseif canImport(UIKit)

import UIKit
public typealias AttributedString = NSAttributedString
public typealias UnderlineStyle = NSUnderlineStyle

#else

#error("No known attributed string type is available")

#endif
