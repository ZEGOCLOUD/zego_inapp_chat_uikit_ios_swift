//
//  HUDHelper.swift
//  ZIMKitDemo
//
//  Created by Kael Ding on 2022/8/3.
//

import Foundation
import ZIMKit

class HUDHelper {

    static func dismiss(_ immediately: Bool = true) {
        ProgressHUD.dismiss(immediately)
    }

    static func showLoading(_ message: String? = nil) {
        ProgressHUD.animationType = .systemActivityIndicator
        ProgressHUD.show(message, interaction: false)
    }

    static func showMessage(_ message: String) {
        ProgressHUD.animationType = .none
        ProgressHUD.show(message, hide: true, interaction: false)
    }
}
