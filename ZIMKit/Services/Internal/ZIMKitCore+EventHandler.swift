//
//  ZIMKitCore+EventHandler.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/3.
//

import Foundation
import ZIM

extension ZIMKitCore: ZIMEventHandler {
    
    // MARK: - User
    func zim(_ zim: ZIM, connectionStateChanged state: ZIMConnectionState, event: ZIMConnectionEvent, extendedData: [AnyHashable : Any]) {
        for delegate in delegates.allObjects {
            delegate.onConnectionStateChange?(state, event)
        }
    }
    
    // MARK: - Conversation
    func zim(_ zim: ZIM, conversationChanged conversationChangeInfoList: [ZIMConversationChangeInfo]) {
        
        if isConversationInit == false { return }
        
        for changeInfo in conversationChangeInfoList {
            if let index = conversations.firstIndex(where: { con in
                con.id == changeInfo.conversation.conversationID && con.type == changeInfo.conversation.type
            }) {
                conversations.remove(at: index)
            }
            conversations.append(ZIMKitConversation(with: changeInfo.conversation))
        }
        conversations = conversations.sorted { $0.orderKey > $1.orderKey }
        
        for delegate in delegates.allObjects {
            delegate.onConversationListChanged?(conversations)
        }
    }
    
    func zim(_ zim: ZIM, conversationTotalUnreadMessageCountUpdated totalUnreadMessageCount: UInt32) {
        for delegate in delegates.allObjects {
            delegate.onTotalUnreadMessageCountChange?(totalUnreadMessageCount)
        }
    }
    
    // MARK: - Group
    
    
    // MARK: - Message
    func zim(_ zim: ZIM, receivePeerMessage messageList: [ZIMMessage], fromUserID: String) {
        handleReceiveNewMessages(messageList)
    }
    
    func zim(_ zim: ZIM, receiveGroupMessage messageList: [ZIMMessage], fromGroupID: String) {
        handleReceiveNewMessages(messageList)
    }
    
    func zim(_ zim: ZIM, receiveRoomMessage messageList: [ZIMMessage], fromRoomID: String) {
        handleReceiveNewMessages(messageList)
    }
    
    
    
    private func handleReceiveNewMessages(_ zimMessageList: [ZIMMessage]) {
        
        if zimMessageList.count == 0 { return }
        
        let zimMessageList = zimMessageList.sorted { $0.timestamp < $1.timestamp }
        let kitMessages = zimMessageList.compactMap({ ZIMKitMessage(with: $0) })
        
        for msg in kitMessages {
            updateKitMessageProperties(msg)
            msg.info.senderUserName = userDict[msg.info.senderUserID]?.name
            msg.info.senderUserAvatarUrl = userDict[msg.info.senderUserID]?.avatarUrl
            messageList.add([msg])
          
            let conversationID = msg.info.conversationID
            let conversationType = msg.info.conversationType
            
            for delegate in delegates.allObjects {
                delegate.onMessageReceived?(conversationID,
                                            type: conversationType,
                                            messages: kitMessages)
            }
        }
    }
    
    func zim(_ zim: ZIM, messageRevokeReceived messageList: [ZIMRevokeMessage]) {
        
        if messageList.count == 0 { return }
        
        let zimMessageList = messageList.sorted { $0.timestamp < $1.timestamp }
        let kitMessages = zimMessageList.compactMap({ ZIMKitMessage(with: $0) })
        
        for msg in kitMessages {
            updateKitMessageProperties(msg)
            
            self.messageList.delete([msg])
            self.messageList.add([msg])
            
        }
        for delegate in delegates.allObjects {
            delegate.onMessageRevoked?(messageList)
        }
    }
    
    func zim(_ zim: ZIM, groupMemberStateChanged state: ZIMGroupMemberState, event: ZIMGroupMemberEvent, userList: [ZIMGroupMemberInfo], operatedInfo: ZIMGroupOperatedInfo, groupID: String) {
        if isConversationInit == false { return }
        for delegate in delegates.allObjects {
            delegate.onGroupMemberStateChanged?(state, event: event, groupID: groupID)
        }
    }
                         
    func zim(_ zim: ZIM, messageReactionsChanged reactions: [ZIMMessageReaction]) {
        if reactions.count == 0 { return }
        for delegate in delegates.allObjects {
            delegate.onMessageReactionsChanged?(reactions)
        }
    }
}
