//
//  NavigationController.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/10.
//

import Foundation

open class NavigationController: UINavigationController {

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.interactivePopGestureRecognizer?.delegate = self

        let view = UIView()
        view.backgroundColor = .zim_backgroundGray3
        navigationBar.addSubview(view)
        view.frame = CGRect(x: 0, y: navigationBar.bounds.height-1, width: navigationBar.bounds.width, height: 1)
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
}

extension NavigationController {

    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }

    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if viewControllers.count > 1 {
            let vc = viewControllers.last
            vc?.hidesBottomBarWhenPushed = true
        }
        super.setViewControllers(viewControllers, animated: animated)
    }

    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if viewControllers.count > 1 {
            topViewController?.hidesBottomBarWhenPushed = false
        }
        return super.popToRootViewController(animated: animated)
    }
}

extension NavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            if visibleViewController == viewControllers.first {
                return false
            }
        }
        return true
    }
}
