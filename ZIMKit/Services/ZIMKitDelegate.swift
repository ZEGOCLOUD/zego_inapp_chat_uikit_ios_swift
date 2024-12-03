//
//  ZIMKitDelegate.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/12/28.
//

import Foundation
import ZIM

@objc public protocol ZIMKitDelegate: AnyObject {
    @objc optional
    func onConnectionStateChange(_ state: ZIMConnectionState, _ event: ZIMConnectionEvent)

    @objc optional
    func onTotalUnreadMessageCountChange(_ totalCount: UInt32)
    
    @objc optional
    func onConversationListChanged(_ conversations: [ZIMKitConversation])
    
    // MARK: - Message
    @objc optional
    func onMessagePreSending(_ message: ZIMKitMessage) -> ZIMKitMessage?
    
    @objc optional
    func onMessageReceived(_ conversationID: String,
                           type: ZIMConversationType,
                           messages: [ZIMKitMessage])
    
    @objc optional
    func onHistoryMessageLoaded(_ conversationID: String,
                                type: ZIMConversationType,
                                messages: [ZIMKitMessage])
    
    @objc optional
    func onMessageDeleted(_ conversationID: String,
                          type: ZIMConversationType,
                          messages: [ZIMKitMessage])
    
    @objc optional
    func onMessageRevoked(_ messages: [ZIMRevokeMessage])
  
    @objc optional
    func onMessageSentStatusChanged(_ message: ZIMKitMessage)
    
    @objc optional
    func onMediaMessageUploadingProgressUpdated(_ message: ZIMKitMessage, uploadProgress: CGFloat)
    
    @objc optional
    func onMediaMessageDownloadingProgressUpdated(_ message: ZIMKitMessage, isFinished: Bool)
    
    @objc optional
    func onMediaMessageDownloadCompleteUpdated(_ message: ZIMKitMessage, isFinished: Bool)
    
    @objc optional
    func onErrorToastCallback(_ errorCode: UInt, defaultMessage: String) -> String?
    
    @objc optional
    func onGroupMemberStateChanged(_ state: ZIMGroupMemberState, event: ZIMGroupMemberEvent,groupID: String)
  
    @objc optional
    func onMessageReactionsChanged(_ reactions: [ZIMMessageReaction])

}
