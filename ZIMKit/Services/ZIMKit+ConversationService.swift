//
//  ZIMKit+ConversationService.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/12/30.
//

import Foundation
import ZIM

extension ZIMKit {
    
    public static func getConversationList(_ callback: GetConversationListCallback? = nil) {
        ZIMKitCore.shared.getConversationList(callback)
    }
        
    public static func deleteConversation(by conversationID: String,
                                          type: ZIMConversationType,
                                          callback: DeleteConversationCallback? = nil) {
        ZIMKitCore.shared.deleteConversation(by: conversationID,
                                             type: type,
                                             callback: callback)
    }
    
    public static func clearUnreadCount(for conversationID: String,
                                        type: ZIMConversationType,
                                        callback: ClearUnreadCountCallback? = nil) {
        ZIMKitCore.shared.clearUnreadCount(for: conversationID, type: type, callback: callback)
    }
    
    public static func loadMoreConversation(_ callback: LoadMoreConversationCallback? = nil) {
        ZIMKitCore.shared.loadMoreConversation(callback: callback)
    }
}
