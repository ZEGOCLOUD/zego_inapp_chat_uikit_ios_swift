//
//  UIImage+Extension.swift
//  ZIMKitConversation
//
//  Created by Kael Ding on 2022/8/4.
//

import Foundation
import UIKit
import Kingfisher

public func loadImageSafely(with imageName: String) -> UIImage {
    if let image = UIImage(named: imageName, in: .ZIMKit) {
        return image.withRenderingMode(.alwaysOriginal)
    } else {
        assertionFailure("\(imageName) image has failed to load from the bundle please make sure it's included in your assets folder.")
        return UIImage()
    }
}

public extension UIImage {
    convenience init?(named name: String, in bundle: Bundle) {
        self.init(named: name, in: bundle, compatibleWith: nil)
    }
}

public extension UIImage {


    /// Create and return a 1x1 point size image with the given color.
    static func image(with color: UIColor) -> UIImage? {
        return self.image(with: color, size: CGSize(width: 1, height: 1))
    }

    /// Create and return a pure color image with the given color and size.
    static func image(with color: UIColor, size: CGSize) -> UIImage? {
        if size.width <= 0 || size.height <= 0 { return nil }

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}

public extension UIImage {
    func gifData() -> Data? {
        kf.gifRepresentation()
    }

    func data() -> Data? {
        if let gifData = gifData() {
            return gifData
        } else {
            return kf.pngRepresentation()
        }
    }
}
