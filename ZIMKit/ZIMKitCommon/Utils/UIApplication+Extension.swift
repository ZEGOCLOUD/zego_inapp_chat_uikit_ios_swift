//
//  UIApplication+Extension.swift
//  ZIMKitCommon
//
//  Created by Kael Ding on 2022/7/29.
//

import Foundation
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

extension UIApplication {
    public class func topViewController(
        base: UIViewController? = UIApplication.key?.rootViewController
    ) -> UIViewController? {

        // UINavigationController
        if let nav = base as? UINavigationController {
            return self.topViewController(base: nav.visibleViewController)
        }

        // UITabBarController
        if let tab = base as? UITabBarController {
            return self.topViewController(base: tab.selectedViewController)
        }

        // presented view controller
        if let presented = base?.presentedViewController {
            return self.topViewController(base: presented)
        }

        return base
    }
}
