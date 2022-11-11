//
//  MessageListVC+Notification.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/14.
//

import Foundation

extension MessagesListVC {
    func addNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(application(willResignActive:)),
            name: UIApplication.willResignActiveNotification,
            object: nil)
    }

    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }

    @objc private func application(willResignActive notification: Notification) {
        audioPlayer.stop()
        hideOptionsView()
    }
}
