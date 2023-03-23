//
//  ZIMKitCore+Conversation.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/9.
//

import Foundation
import ZIM

extension ZIMKitCore {
    func getConversationList(_ callback: GetConversationListCallback? = nil) {
        if conversations.count > 0 {
            let error = ZIMError()
            error.code = .success
            callback?(conversations, error)
        } else {
            loadMoreConversation(false) { error in
                if error.code == .success {
                    self.isConversationInit = true
                }
                callback?(self.conversations, error)
            }
        }
    }
    func deleteConversation(by conversationID: String,
                            type: ZIMConversationType,
                            callback: DeleteConversationCallback? = nil) {
        let index = self.conversations.firstIndex { con in
            con.id == conversationID && con.type == type
        }
        if let index = index {
            self.conversations.remove(at: index)
        }
        
        let config = ZIMConversationDeleteConfig()
        config.isAlsoDeleteServerConversation = true
        zim?.deleteConversation(by: conversationID,
                                conversationType: type,
                                config: config, callback: { conversationID, type, error in
            callback?(error)
            
            for delegate in self.delegates.allObjects {
                delegate.onConversationListChanged?(self.conversations)
            }
        })
    }
    
    func clearUnreadCount(for conversationID: String,
                          type: ZIMConversationType,
                          callback: ClearUnreadCountCallback? = nil) {
        zim?.clearConversationUnreadMessageCount(for: conversationID, conversationType: type, callback: { _, _, error in
            callback?(error)
        })
    }
    
    func loadMoreConversation(_ isCallbackListChanged: Bool = true,
                              callback: LoadMoreConversationCallback? = nil) {
        if isLoadedAllConversations { return }
        let quryConfig = ZIMConversationQueryConfig()
        quryConfig.count = 100
        quryConfig.nextConversation = conversations.last?.zim
        zim?.queryConversationList(with: quryConfig, callback: { zimConversations, error in
            if error.code != .success {
                callback?(error)
                return
            }
            
            self.isLoadedAllConversations = zimConversations.count < quryConfig.count
            
            let newConversations = zimConversations.compactMap({ ZIMKitConversation(with: $0) })
            self.conversations.append(contentsOf: newConversations)
            self.conversations = self.conversations.sorted { $0.orderKey > $1.orderKey }
            
            callback?(error)
            
            if isCallbackListChanged == false { return }
            
            for delegate in self.delegates.allObjects {
                delegate.onConversationListChanged?(self.conversations)
            }
        })
    }
}
