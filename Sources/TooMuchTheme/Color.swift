import Foundation

#if canImport(AppKit)

import AppKit
typealias Color = NSColor

#elseif canImport(UIKit)

import UIKit
typealias Color = UIColor

#else

#error("No known color type compatible with attributed strings is available")

#endif

// Thanks to https://gist.github.com/rpomeroy/c0bf58a2c62f34fdad8d

extension Color {
    
    convenience init(hexWithAlpha hex: UInt32) {
        let red = CGFloat((hex >> 24) & 0xFF) / 255.0
        let green = CGFloat((hex >> 16) & 0xFF) / 255.0
        let blue = CGFloat((hex >> 8) & 0xFF) / 255.0
        let alpha = CGFloat(hex & 0xFF) / 255.0
        #if canImport(AppKit) // NSColor
        self.init(calibratedRed: red, green: green, blue: blue, alpha: alpha)
        #else // UIColor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
        #endif
    }
    
    convenience init(hex: String) throws {
        var string = hex
        if string.hasPrefix("#") {
            string.removeFirst()
        }
        
        var value: UInt32 = 0
        guard Scanner(string: string).scanHexInt32(&value) else {
            throw ColorParseError(string: hex, reason: .notHexInteger)
        }
        
        guard value <= 0xFFFFFFFF else {
            throw ColorParseError(string: hex, reason: .overflow)
        }
        
        if value & 0xFF000000 != 0 {
            self.init(hexWithAlpha: value)
        } else {
            self.init(hexWithAlpha: (value << 8) | 0xFF)
        }
    }
    
}

public struct ColorParseError: LocalizedError {
    
    public var string: String
    public var reason: Reason
    
    public enum Reason {
        
        case notHexInteger
        case overflow
        
    }
    
    public var errorDescription: String? {
        "Could not parse a color from \(string)"
    }
    
    public var failureReason: String? {
        switch reason {
        case .notHexInteger:
            return "Not a hexadecimal integer"
        case .overflow:
            return "Value too large"
        }
    }
    
}
