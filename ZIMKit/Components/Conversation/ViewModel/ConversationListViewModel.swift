//
//  ConversationViewModel.swift
//  ZIMKitConversation
//
//  Created by Kael Ding on 2022/8/1.
//

import Foundation
import ZIM

class ConversationListViewModel: NSObject {

    /// conversations of current user.
    @ZIMKitObservable var conversations: [ZIMKitConversation] = []

    override init() {
        super.init()
        ZIMKit.registerZIMKitDelegate(self)
    }
}

extension ConversationListViewModel {
    
    func getConversationList(_ callback: (([ZIMKitConversation], ZIMError) -> Void)?) {
        ZIMKit.getConversationList { conversations, error in
            self.conversations = conversations
            callback?(conversations, error)
        }
    }
    
    func loadMoreConversations() {
        ZIMKit.loadMoreConversation()
    }
    
    func clearConversationUnreadMessageCount(_ conversationID: String, type: ZIMConversationType) {
        ZIMKit.clearUnreadCount(for: conversationID, type: type)
    }
    
    func deleteConversation(_ conversation: ZIMKitConversation, callback: ((ZIMError) -> Void)?) {
        conversations = conversations.filter({ $0 !== conversation })
        ZIMKit.deleteConversation(by: conversation.id, type: conversation.type) { error in
            callback?(error)
        }
    }
  
  func updateConversationPinnedState(_ conversation: ZIMKitConversation, isPinned: Bool,  callback: ((ZIMError) -> Void)?) {
        ZIMKit.updateConversationPinnedState(for: conversation.id, type: conversation.type, isPinned: isPinned) { error in
          callback?(error)
        }
    }
}

extension ConversationListViewModel: ZIMKitDelegate {
    func onConversationListChanged(_ conversations: [ZIMKitConversation]) {
        self.conversations = conversations
    }
  
}
