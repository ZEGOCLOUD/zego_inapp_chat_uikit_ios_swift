//
//  ProgressHUD+Extension.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/8.
//

import Foundation

class HUDHelper {
    static func showMessage(_ message: String) {
        dismiss(true)
        ProgressHUD.animationType = .none
        ProgressHUD.show(message, hide: true, interaction: true)
    }

    static func showLoading(_ message: String? = nil) {
        dismiss(true)
        ProgressHUD.animationType = .systemActivityIndicator
        ProgressHUD.show(message, interaction: false)
    }

    static func showImage(_ imageName: String, message: String? = nil) {
        dismiss(true)
        let image = loadImageSafely(with: imageName)
        ProgressHUD.show(message, icon: image, interaction: true)
    }

    static func dismiss(_ immediately: Bool = false) {
        ProgressHUD.dismiss(immediately)
    }
}
