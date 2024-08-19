//
//  ZIMKit+ConversationService.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/12/30.
//

import Foundation
import ZIM

extension ZIMKit {
    
    @objc public static func getConversationList(_ callback: GetConversationListCallback? = nil) {
        ZIMKitCore.shared.getConversationList(callback)
    }
    
    @objc public static func deleteConversation(by conversationID: String,
                                          type: ZIMConversationType,
                                          callback: DeleteConversationCallback? = nil) {
        ZIMKitCore.shared.deleteConversation(by: conversationID,
                                             type: type,
                                             callback: callback)
    }
    
    @objc public static func clearUnreadCount(for conversationID: String,
                                        type: ZIMConversationType,
                                        callback: ClearUnreadCountCallback? = nil) {
        ZIMKitCore.shared.clearUnreadCount(for: conversationID, type: type, callback: callback)
    }
    
    @objc public static func loadMoreConversation(_ callback: LoadMoreConversationCallback? = nil) {
        ZIMKitCore.shared.loadMoreConversation(callback: callback)
    }
  
    @objc public static func updateConversationPinnedState(for conversationID: String,
                                                           type: ZIMConversationType,
                                                           isPinned: Bool,
                                                           callback: UpdateConversationPinnedStateCallback? = nil) {
        ZIMKitCore.shared.updateConversationPinnedState(for: conversationID, type: type, isPinned: isPinned, callback: callback)
    }
  
    @objc public static func setConversationNotificationStatus(for conversationID: String,
                                                           type: ZIMConversationType,
                                                                    status:ZIMConversationNotificationStatus,
                                                           callback: SetConversationNotificationStatusSetCallback? = nil) {
        ZIMKitCore.shared.setConversationNotificationStatus(for: conversationID, type: type, status: status, callback: callback)
    }
  
      @objc public static func queryConversation(for conversationID: String,
                                                             type: ZIMConversationType,
                                                             callback: QueryConversationQueriedCallback? = nil) {
        ZIMKitCore.shared.queryConversation(conversationID: conversationID, type: type, callback: callback)
    }
  
  
}
