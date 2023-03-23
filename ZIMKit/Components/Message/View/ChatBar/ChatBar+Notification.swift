//
//  ChatBar+Notification.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/15.
//

import Foundation

extension ChatBar {

    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(application(willResignActive:)),
            name: UIApplication.willResignActiveNotification,
            object: nil)
    }

    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ noti: Notification) {

    }

    @objc private func keyboardWillHide(_ noti: Notification) {

    }

    @objc private func keyboardWillChangeFrame(_ noti: Notification) {
        guard let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        keyboardFrame = frame

        if let duration = noti.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
           duration > 0 {
            keyboardAnimationDuration = duration
        }

        guard let superview = superview else { return }
        let isKeyboardHide = keyboardFrame.origin.y >= superview.frame.height

        if isKeyboardHide == false && status == .keybaord {
            updateChatBarConstraints()
        }
    }

    @objc private func application(willResignActive notification: Notification) {
        endRecord()
    }
}
