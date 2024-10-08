//
//  ZIMKit+MessageService.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/12/29.
//

import Foundation
import ZIM

extension ZIMKit {
    @objc public static func getMessageList(with conversationID: String,
                                      type: ZIMConversationType,
                                      callback: GetMessageListCallback? = nil) {
        ZIMKitCore.shared.getMessageList(with: conversationID, type: type, callback: callback)
    }
    
    @objc public static func loadMoreMessage(with conversationID: String,
                                       type: ZIMConversationType,
                                       callback: LoadMoreMessageCallback? = nil) {
        ZIMKitCore.shared.loadMoreMessage(with: conversationID, type: type, callback: callback)
    }
    
    @objc public static func sendTextMessage(_ text: String,
                                       to conversationID: String,
                                       type: ZIMConversationType,
                                       conversationName:String = "",
                                       callback: MessageSentCallback? = nil) {
        ZIMKitCore.shared.sendTextMessage(text,
                                          to: conversationID,
                                          type: type,
                                          conversationName:conversationName,
                                          callback: callback)
    }
    
    @objc public static func sendImageMessage(_ imagePath: String,
                                        to conversationID: String,
                                        type: ZIMConversationType,
                                        conversationName:String = "",
                                        callback: MessageSentCallback? = nil) {
        ZIMKitCore.shared.sendImageMessage(imagePath,
                                           to: conversationID,
                                           type: type,
                                           conversationName:conversationName,
                                           callback: callback)
    }
    
    @objc public static func sendAudioMessage(_ audioPath: String,
                                        duration: UInt32 = 0,
                                        to conversationID: String,
                                        type: ZIMConversationType,
                                        conversationName:String = "",
                                        callback: MessageSentCallback? = nil) {
        ZIMKitCore.shared.sendAudioMessage(audioPath,
                                           duration: duration,
                                           to: conversationID,
                                           type: type,
                                           conversationName:conversationName,
                                           callback: callback)
    }
    
    @objc public static func sendVideoMessage(_ videoPath: String,
                                        duration: UInt32 = 0,
                                        to conversationID: String,
                                        type: ZIMConversationType,
                                        conversationName:String = "",
                                        callback: MessageSentCallback? = nil) {
        ZIMKitCore.shared.sendVideoMessage(videoPath,
                                           duration: duration,
                                           to: conversationID,
                                           type: type,
                                           conversationName:conversationName,
                                           callback: callback)
    }
    
    @objc public static func sendFileMessage(_ filePath: String,
                                       to conversationID: String,
                                       type: ZIMConversationType,
                                       conversationName:String = "",
                                       callback: MessageSentCallback? = nil) {
        ZIMKitCore.shared.sendFileMessage(filePath,
                                          to: conversationID,
                                          type: type,
                                          conversationName:conversationName,
                                          callback: callback)
    }
  
  
    @objc public static func revokeMessage(_ message: ZIMKitMessage,
                                           config: ZIMMessageRevokeConfig = ZIMMessageRevokeConfig(),
                                       callback: revokeMessageCallback? = nil) {
        ZIMKitCore.shared.revokeMessage(message, config: config, callback: callback)
    }
    
    @objc public static func downloadMediaFile(with message: ZIMKitMessage,
                                         callback: DownloadMediaFileCallback? = nil) {
        ZIMKitCore.shared.downloadMediaFile(with: message, callback: callback)
    }
    
    @objc public static func deleteMessage(_ messages: [ZIMKitMessage],
                                      callback: DeleteMessageCallback? = nil) {
        ZIMKitCore.shared.deleteMessage(messages, callback: callback)
    }
}
