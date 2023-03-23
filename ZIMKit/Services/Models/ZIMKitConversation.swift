//
//  ZIMKitConversation.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/6.
//

import Foundation
import ZIM

public class ZIMKitConversation: NSObject {
    public var id: String = ""
    public var name: String = ""
    public var avatarUrl: String = ""
    public var type: ZIMConversationType = .peer
    public var notificationStatus: ZIMConversationNotificationStatus = .notify
    public var unreadMessageCount: UInt32 = 0
    public var lastMessage: ZIMKitMessage?
    public var orderKey: Int64 = 0
    
    var zim: ZIMConversation
    
    init(with con: ZIMConversation) {
        zim = con
        id = con.conversationID
        name = con.conversationName
        avatarUrl = con.conversationAvatarUrl
        type = con.type
        notificationStatus = con.notificationStatus
        unreadMessageCount = con.unreadMessageCount
        orderKey = con.orderKey
        if con.lastMessage != nil {
            lastMessage = ZIMKitMessage(with: con.lastMessage)
        }
    }
}
