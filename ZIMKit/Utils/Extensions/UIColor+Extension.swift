//
//  UIColor+Extension.swift
//  ZIMKitCommon
//
//  Created by Kael Ding on 2022/8/2.
//

import Foundation
import UIKit

public extension UIColor {
    convenience init(hex: UInt32, a: CGFloat = 1.0) {
        self.init(
            r: (hex >> 16) & 0xFF,
            g: (hex >> 8) & 0xFF,
            b: hex & 0xFF,
            a: a
        )
    }

    convenience init(r: UInt32, g: UInt32, b: UInt32, a: CGFloat = 1.0) {
        assert(r >= 0 && r <= 255, "Invalid red component")
        assert(g >= 0 && g <= 255, "Invalid green component")
        assert(b >= 0 && b <= 255, "Invalid blue component")
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: a)
    }
}

public extension UIColor {

}

/// get color with name in Assets
public func loadColorSafely(_ colorName: String) -> UIColor {
    if let color = UIColor(named: colorName, in: .ZIMKit, compatibleWith: nil) {
        return color
    } else {
        assertionFailure(
            """
            \(colorName) color has failed to load from the bundle please make sure it's included in your assets folder.
            A default 'white' color has been added.
            """
        )
        return UIColor.white
    }
}
