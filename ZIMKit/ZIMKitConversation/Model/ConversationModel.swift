//
//  ConversationModel.swift
//  ZIMKitConversation
//
//  Created by Kael Ding on 2022/8/5.
//

import Foundation
import ZIM

class ConversationModel {
    /// A unique identifier of conversation.
    let conversationID: String

    /// The name of conversation.
    var conversationName: String

    /// The avatar url of conversation.
    var conversationAvatarUrl: String

    /// The  type of conversation: `peer`, `room` and `group`.
    var type: ConversationType

    /// The total number of unread messages.
    var unreadMessageCount: UInt32

    /// The last message of conversation.
    var lastMessage: ZIMMessage?

    /// OrderKey is used to describe the order of messages in the session. The larger orderKey is, the newer it is.
    var orderKey: Int64

    /// session notification status.
    var notificationStatus: ZIMConversationNotificationStatus

    init(with con: ZIMConversation) {
        conversationID = con.conversationID
        conversationName = con.conversationName
        conversationAvatarUrl = con.conversationAvatarUrl
        type = con.type == .peer ? .peer : .group
        unreadMessageCount = con.unreadMessageCount
        lastMessage = con.lastMessage
        orderKey = con.orderKey
        notificationStatus = con.notificationStatus
    }

    func toZIMModel() -> ZIMConversation {
        let con = ZIMConversation()
        con.conversationID = conversationID
        con.conversationName = conversationName
        con.conversationAvatarUrl = conversationAvatarUrl
        con.type = type == .peer ? .peer : .group
        con.unreadMessageCount = unreadMessageCount
        if let lastMessage = lastMessage {
            con.lastMessage = lastMessage
        }
        con.orderKey = orderKey
        con.notificationStatus = notificationStatus
        return con
    }

    func update(with con: ZIMConversation) {
        assert(conversationID == con.conversationID, "Update Conversation failed, conversationID should be equal!")
        conversationName = con.conversationName
        conversationAvatarUrl = con.conversationAvatarUrl
        type = con.type == .peer ? .peer : .group
        unreadMessageCount = con.unreadMessageCount
        lastMessage = con.lastMessage
        orderKey = con.orderKey
        notificationStatus = con.notificationStatus
    }
}
