//
//  LocalAPNS.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/1.
//

import Foundation
import ZIM

public let LocalNotificationRequestId = "LocalNotificationRequestId"

public class LocalAPNS: NSObject, ZIMEventHandler {
    static let shared = LocalAPNS()

    private var keepAliveTask: UIBackgroundTaskIdentifier?

    private override init() {
        super.init()
        addNotifications()
    }

    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc func didEnterBackground(_ noti: Notification) {
        let application = UIApplication.shared
        keepAliveTask = application.beginBackgroundTask(expirationHandler: {
            guard let keepAliveTask = self.keepAliveTask else { return }
            application.endBackgroundTask(keepAliveTask)
        })
        if keepAliveTask == .invalid { return }
    }

    @objc func didBecomeActive(_ noti: Notification) {
        if let keepAliveTask = keepAliveTask {
            UIApplication.shared.endBackgroundTask(keepAliveTask)
        }
        keepAliveTask = .invalid
    }

    public func setupLocalAPNS() {
        ZIMKitManager.shared.addZIMEventHandler(self)
    }

    // MARK: - ZIMEventHandler
    public func zim(_ zim: ZIM, receivePeerMessage messageList: [ZIMMessage], fromUserID: String) {
        handleReceiveMessages(messageList, fromID: fromUserID)
    }

    public func zim(_ zim: ZIM, receiveGroupMessage messageList: [ZIMMessage], fromGroupID: String) {
        handleReceiveMessages(messageList, fromID: fromGroupID)
    }

    public func zim(_ zim: ZIM, receiveRoomMessage messageList: [ZIMMessage], fromRoomID: String) {
        handleReceiveMessages(messageList, fromID: fromRoomID)
    }

    // MARK: - Private
    private func handleReceiveMessages(_ messageList: [ZIMMessage], fromID: String) {
        let isBackground = UIApplication.shared.applicationState == .background
        if !isBackground { return }

        // sort the messages
        let messageList = messageList.sorted { $0.timestamp < $1.timestamp }
        for message in messageList {
            addLocalNotice(message)
        }
    }

    private func addLocalNotice(_ message: ZIMMessage) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.body = message.getShortString()
        content.sound = .default

        content.userInfo = ["conversationID": message.conversationID, "conversationType": message.conversationType.rawValue]
        let request = UNNotificationRequest(identifier: LocalNotificationRequestId, content: content, trigger: nil)
        center.add(request)
    }
}
