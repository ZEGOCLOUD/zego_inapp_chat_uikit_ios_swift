//
//  LocalAPNS.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/1.
//

import Foundation
import ZIM

public let LocalNotificationRequestId = "LocalNotificationRequestId"

public class LocalAPNS: NSObject {
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
        ZIMKit.registerZIMKitDelegate(self)
    }

    // MARK: - Private
    private func handleReceiveMessages(_ messageList: [ZIMKitMessage], fromID: String) {
        let isBackground = UIApplication.shared.applicationState == .background
        if !isBackground { return }

        // sort the messages
        let messageList = messageList.sorted { $0.info.timestamp < $1.info.timestamp }
        for message in messageList {
            addLocalNotice(message)
        }
    }

    private func addLocalNotice(_ message: ZIMKitMessage) {
    
        if message.info.conversationType == .peer {
            ZIMKit.queryUserInfo(by: message.info.senderUserID) { userInfo, error in
                let center = UNUserNotificationCenter.current()
                let content = UNMutableNotificationContent()
                content.body = message.getShortString()
                content.sound = .default
                content.title = userInfo?.name ?? ""
                content.userInfo = ["conversationID": message.info.conversationID, "conversationType": message.info.conversationType.rawValue]
                let request = UNNotificationRequest(identifier: LocalNotificationRequestId, content: content, trigger: nil)
                center.add(request)
            }
        } else if message.info.conversationType == .group {
            ZIMKit.queryGroupInfo(by: message.info.conversationID) { groupInfo, error in
                let center = UNUserNotificationCenter.current()
                let content = UNMutableNotificationContent()
                content.body = message.getShortString()
                content.sound = .default
                content.title = groupInfo.name
                content.userInfo = ["conversationID": message.info.conversationID, "conversationType": message.info.conversationType.rawValue]
                let request = UNNotificationRequest(identifier: LocalNotificationRequestId, content: content, trigger: nil)
                center.add(request)
            }
        }

    }
}

extension LocalAPNS: ZIMKitDelegate {
    public func onMessageReceived(_ conversationID: String, type: ZIMConversationType, messages: [ZIMKitMessage]) {
        if messages.count == 0 { return }
        let senderUserID = messages.first!.info.senderUserID
        let isFromSelf = senderUserID == ZIMKit.localUser?.id
        if isFromSelf { return }
        handleReceiveMessages(messages, fromID: senderUserID)
    }
}
