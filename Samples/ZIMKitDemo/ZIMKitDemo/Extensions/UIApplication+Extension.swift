//
//  UIApplication+Extension.swift
//  ZIMKitDemo
//
//  Created by Kael Ding on 2022/8/4.
//

import UIKit

extension UIApplication {
    /// get the key window of application
    public static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
