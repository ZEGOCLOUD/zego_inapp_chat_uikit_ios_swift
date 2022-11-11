//
//  DispatchManager.swift
//  Pods-ZIMKitDemo
//
//  Created by Kael Ding on 2022/7/29.
//

import Foundation
import UIKit

public let Dispatcher: DispatcherManager = DispatcherManager()

public class DispatcherManager {

    @discardableResult
    public func open(_ target: DispatchProtocol) -> UIViewController? {
        guard let vc = self.viewController(of: target) else {
            return nil
        }

        if let navigationVC = UIApplication.topViewController()?.navigationController {
            navigationVC.pushViewController(vc, animated: true)
        } else {
            let navigationVC = NavigationController(rootViewController: vc)
            //            navigationVC.modalPresentationStyle = .custom
            UIApplication.topViewController()?.present(navigationVC, animated: true)
        }

        return vc
    }

    public func action(of target: DispatchProtocol) -> AnyObject? {
        guard let t = target as? DispatchActionProtocol else {
            print("⚠️DISPATCHER WARNINIG: \(type(of: target)) does not conform to DispatchActionProtocol")
            return nil
        }
        return t.callAction()
    }
}

extension DispatcherManager {
    public func viewController(of target: DispatchProtocol) -> UIViewController? {
        guard let t = target as? DispatchViewControllerProtocol else {
            print("⚠️DISPATCHER WARNING: \(target) does not conform to DispatchViewControllerProtocol.")
            return nil
        }
        guard let vc = t.viewController() else {
            return nil
        }
        return vc
    }
}

extension UIViewController {

}
