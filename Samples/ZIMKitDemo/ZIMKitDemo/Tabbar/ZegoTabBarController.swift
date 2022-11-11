//
//  ZegoTabBarController.swift
//  ZIMKitDemo
//
//  Created by Kael Ding on 2022/8/4.
//

import Foundation
import UIKit

class ZegoTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        let view = UIView()
        view.backgroundColor = .init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        tabBar.addSubview(view)
        view.frame = CGRect(x: 0, y: 0, width: tabBar.bounds.width, height: 1.0)
    }

    func setupControllers(_ controllers: [UIViewController]) {
        self.viewControllers = controllers
        self.tabBar.tintColor = UIColor(hex: 0x666666)
    }
}
