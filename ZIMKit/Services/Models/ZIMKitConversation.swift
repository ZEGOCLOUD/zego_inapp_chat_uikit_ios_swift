//
//  ZIMKitConversation.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/6.
//

import Foundation
import ZIM

public class ZIMKitConversation: NSObject {
    @objc public var id: String = ""
    @objc public var name: String = ""
    @objc public var avatarUrl: String = ""
    @objc public var type: ZIMConversationType = .peer
    @objc public var notificationStatus: ZIMConversationNotificationStatus = .notify
    @objc public var unreadMessageCount: UInt32 = 0
    @objc public var lastMessage: ZIMKitMessage?
    @objc public var orderKey: Int64 = 0
    @objc public var isPinned: Bool = false
    var zim: ZIMConversation
    
    init(with con: ZIMConversation) {
        zim = con
        id = con.conversationID
        name = con.conversationName
        avatarUrl = con.conversationAvatarUrl
        type = con.type
        isPinned = con.isPinned
        notificationStatus = con.notificationStatus
        unreadMessageCount = con.unreadMessageCount
        orderKey = con.orderKey
        if con.lastMessage != nil {
            lastMessage = ZIMKitMessage(with: con.lastMessage)
        }
    }
}
