//
//  ZIMKit+MessageService.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/12/29.
//

import Foundation
import ZIM

let systemMessageSubType: UInt32 = 30

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
    
    @objc public static func sendCombineMessage(conversationID:String,
                                                type:ZIMConversationType,
                                                content:String,
                                                conversationName:String = "",
                                                combineTitle:String,
                                                messageList:[ZIMKitMessage],
                                                callback: sendCombineMessageCallback? = nil){
        
        ZIMKitCore.shared.sendCombineMessage(conversationID: conversationID,
                                             type: type,
                                             content: content,
                                             conversationName: conversationName,
                                             combineTitle:combineTitle,
                                             messageList: messageList,
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
                                              firstFrameDownloadUrl:String = "",
                                              callback: MessageSentCallback? = nil) {
        ZIMKitCore.shared.sendVideoMessage(videoPath,
                                           duration: duration,
                                           to: conversationID,
                                           type: type,
                                           conversationName:conversationName,
                                           firstFrameDownloadUrl:firstFrameDownloadUrl,
                                           callback: callback)
    }
    
    @objc public static func sendFileMessage(_ filePath: String,
                                             to conversationID: String,
                                             type: ZIMConversationType,
                                             conversationName:String = "",
                                             fileName:String = "",
                                             callback: MessageSentCallback? = nil) {
        ZIMKitCore.shared.sendFileMessage(filePath,
                                          to: conversationID,
                                          type: type,
                                          conversationName:conversationName,
                                          fileName:fileName,
                                          callback: callback)
    }
    
    
    @objc public static func revokeMessage(_ message: ZIMKitMessage,
                                           config: ZIMMessageRevokeConfig = ZIMMessageRevokeConfig(),
                                           callback: revokeMessageCallback? = nil) {
        ZIMKitCore.shared.revokeMessage(message, config: config, callback: callback)
    }
    
    @objc public static func replyMessage(_ messageType:ZIMMessageType,
                                          originMessage:ZIMKitMessage,
                                          conversationName:String,
                                          content:String,
                                          conversationID:String,
                                          type: ZIMConversationType,
                                          duration: UInt32 = 0,
                                          firstFrameDownloadUrl:String = "",
                                          fileName:String = "",
                                          callback: replyMessageCallback? = nil) {
        
        ZIMKitCore.shared.replyMessage(messageType,
                                       originMessage: originMessage,
                                       conversationName: conversationName,
                                       content: content,
                                       conversationID: conversationID,
                                       type: type,
                                       duration: duration,
                                       firstFrameDownloadUrl: firstFrameDownloadUrl,
                                       fileName: fileName,
                                       callback: callback)
    }
    
    
    @objc public static func downloadMediaFile(with message: ZIMKitMessage,
                                               _ chatRecord:Bool = false,
                                               callback: DownloadMediaFileCallback? = nil) {
        ZIMKitCore.shared.downloadMediaFile(with: message, chatRecord, callback: callback)
    }
    
    @objc public static func deleteMessage(_ messages: [ZIMKitMessage],
                                           callback: DeleteMessageCallback? = nil) {
        ZIMKitCore.shared.deleteMessage(messages, callback: callback)
    }
    
    @objc public static func sendMessageOneByOne(_ conversationList: [ZIMKitMessage],
                                                 targetConversation:ZIMKitConversation,
                                                 callBack:@escaping sendMessageOneByOneCallback) {
        //FIXME: SDK 限频导致不能连续调用 100ms
        ZIMKit.conversationList = conversationList
        ZIMKit.targetConversation = targetConversation
        ZIMKit.oneByOneCallBack = callBack
        startProcessing()
    }
    
    static func startProcessing() {
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(sendNormalMessage), userInfo: nil, repeats: true)
    }
    
    @objc static func sendNormalMessage() {
        if ZIMKit.currentIndex >= ZIMKit.conversationList?.count ?? 0 {
            return
        }
        let targetConversation: ZIMKitConversation = ZIMKit.targetConversation!
        let message: ZIMKitMessage = ZIMKit.conversationList![ZIMKit.currentIndex]
        if message.type == .text {
            if targetConversation.type == .peer {
                ZIMKit.sendTextMessage(message.textContent.content, to: targetConversation.id, type: .peer) { error in
                    if error.code != .ZIMErrorCodeSuccess {
                        
                    }
                }
            } else if targetConversation.type == .group {
                ZIMKit.sendTextMessage(message.textContent.content, to: targetConversation.id, type: .group,conversationName: targetConversation.name) {  error in
                    if error.code != .ZIMErrorCodeSuccess {
                        
                    }
                }
            }
        } else if message.type == .audio {
//            if targetConversation.type == .peer {
//                ZIMKit.sendAudioMessage(message.audioContent.fileDownloadUrl, duration: message.audioContent.duration, to: targetConversation.id, type: .peer) {  error in
//                    if error.code != .ZIMErrorCodeSuccess {
//                        
//                    }
//                }
//            } else if targetConversation.type == .group {
//                ZIMKit.sendAudioMessage(message.audioContent.fileDownloadUrl, duration: message.audioContent.duration, to: targetConversation.id, type: .group,conversationName: targetConversation.name) { error in
//                    if error.code != .ZIMErrorCodeSuccess {
//                        
//                    }
//                }
//            }
            let audioMsg = L10n("common_message_audio")
            if targetConversation.type == .peer {
                ZIMKit.sendTextMessage(audioMsg, to: targetConversation.id, type: .peer) { error in
                    if error.code != .ZIMErrorCodeSuccess {
                        
                    }
                }
            } else if targetConversation.type == .group {
                ZIMKit.sendTextMessage(audioMsg, to: targetConversation.id, type: .group,conversationName: targetConversation.name) {  error in
                    if error.code != .ZIMErrorCodeSuccess {
                        
                    }
                }
            }
        } else if message.type == .image {
            if targetConversation.type == .peer {
                ZIMKit.sendImageMessage(message.imageContent.fileDownloadUrl, to: targetConversation.id, type: .peer) { error in
                    if error.code != .ZIMErrorCodeSuccess {
                        
                    }
                }
            } else if targetConversation.type == .group {
                ZIMKit.sendImageMessage(message.imageContent.fileDownloadUrl, to: targetConversation.id, type: .group,conversationName: targetConversation.name) { error in
                    if error.code != .ZIMErrorCodeSuccess {
                        
                    }
                }
            }
        } else if message.type == .file {
            if targetConversation.type == .peer {
                ZIMKit.sendFileMessage(message.fileContent.fileDownloadUrl, to: targetConversation.id, type: .peer, fileName: message.fileContent.fileName) { error in
                    if error.code != .ZIMErrorCodeSuccess {
                        
                    }
                }
            } else if targetConversation.type == .group {
                ZIMKit.sendFileMessage(message.fileContent.fileDownloadUrl, to: targetConversation.id, type: .group, conversationName: targetConversation.name,fileName: message.fileContent.fileName) { error in
                    if error.code != .ZIMErrorCodeSuccess {
                        
                    }
                }
            }
        } else if message.type == .video {
            if targetConversation.type == .peer {
                ZIMKit.sendVideoMessage(message.videoContent.fileDownloadUrl, duration: message.videoContent.duration, to: targetConversation.id, type: .peer, firstFrameDownloadUrl: message.videoContent.firstFrameDownloadUrl) { error in
                    
                }
            } else if targetConversation.type == .group {
                ZIMKit.sendVideoMessage(message.videoContent.fileDownloadUrl, duration: message.videoContent.duration, to: targetConversation.id, type: .group, conversationName: targetConversation.name, firstFrameDownloadUrl: message.videoContent.firstFrameDownloadUrl) { error in
                    if error.code != .ZIMErrorCodeSuccess {
                        
                    }
                }
            }
        } else if message.type == .combine {
            guard let messageZim = message.zim as? ZIMCombineMessage else { return }
            ZIMKit.queryCombineMessageDetailByMessage(for: message) { conversation, error in
                if error.code == .ZIMErrorCodeSuccess {
                    ZIMKit.sendCombineMessage(conversationID: targetConversation.id, type: targetConversation.type , content: messageZim.summary, conversationName: targetConversation.name, combineTitle:messageZim.title ,messageList: conversation) { error in
                    }
                }
            }
        }
        if ZIMKit.currentIndex < ((ZIMKit.conversationList?.count ?? 1) - 1)  {
            ZIMKit.currentIndex += 1
        } else {
            ZIMKit.oneByOneCallBack?()
            ZIMKit.timer?.invalidate()
            ZIMKit.timer = nil
            ZIMKit.currentIndex = 0
            ZIMKit.targetConversation = nil
            ZIMKit.conversationList = nil
        }
    }
    
    @objc public static func queryCombineMessageDetailByMessage(for message: ZIMKitMessage,
                                                                callback: QueryCombineMessageDetailCallback? = nil) {
        let combineMessage:ZIMCombineMessage = message.zim as! ZIMCombineMessage
        ZIMKitCore.shared.queryCombineMessageDetailByMessage(message: combineMessage, callback: callback)
    }
    
    @objc public static func addMessageReactionByMessage(for message: ZIMKitMessage,
                                                         reactionType:String,
                                                         callback: MessageReactionAddedCallback? = nil) {
        ZIMKitCore.shared.addMessageReaction(message: message, reactionType: reactionType, callback: callback)
    }
    
    @objc public static func deleteMessageReaction(for message: ZIMKitMessage,
                                                   reactionType:String,
                                                   callback: MessageReactionDeletedCallback? = nil) {
        ZIMKitCore.shared.deleteMessageReaction(message: message, reactionType: reactionType, callback: callback)
    }
    
    
    @objc public static func insertMessageToLocalDB(_ message: ZIMKitMessage,
                                                 from senderUserID: String?,
                                                 to conversationID: String,
                                                 type: ZIMConversationType,
                                                 callback: InsertMessageCallback? = nil) {
        ZIMKitCore.shared.insertMessageToLocalDB(message, from: senderUserID, to: conversationID, type: type, callback: callback)
    }
    
    @objc public static func insertSystemMessageToLocalDB(_ content: String,
                                                          to conversationID: String,
                                                          groupConversationType: Bool = false,
                                                          callback: InsertMessageCallback? = nil) {
        let systemMessage: ZIMCustomMessage = ZIMCustomMessage(message: content, subType: systemMessageSubType)
        
        let systemMsg =  ZIMKitMessage(with: systemMessage)
        systemMsg.info.conversationID = conversationID
        ZIMKitCore.shared.insertMessageToLocalDB(systemMsg, from: "", to: conversationID, type: groupConversationType ? .group : .peer, callback: callback)
    }
}
