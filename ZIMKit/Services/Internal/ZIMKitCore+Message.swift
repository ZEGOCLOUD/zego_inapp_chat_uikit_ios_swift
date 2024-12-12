//
//  ZIMKitCore+Message.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/9.
//

import Foundation
import ZIM

let queryMessagePageCount = 30

extension ZIMKitCore {
    func getMessageList(with conversationID: String,
                        type: ZIMConversationType,
                        callback: GetMessageListCallback? = nil) {
        let messages = messageList.get(conversationID, type: type)
        if messages.count >= queryMessagePageCount {
            let error = ZIMError()
            error.code = .ZIMErrorCodeSuccess
            callback?(messages, true, error)
        } else {
            loadMoreMessage(with: conversationID, type: type, isCallbackListChanged: false) { error in
                let messages = self.messageList.get(conversationID, type: type)
                let hasMore: Bool = messages.count >= queryMessagePageCount
                callback?(messages, hasMore, error)
            }
        }
    }
    
    func loadMoreMessage(with conversationID: String,
                         type: ZIMConversationType,
                         isCallbackListChanged: Bool = true,
                         callback: LoadMoreMessageCallback? = nil) {
        let messages = self.messageList.get(conversationID, type: type)
        let config = ZIMMessageQueryConfig()
        config.count = UInt32(queryMessagePageCount)
        config.nextMessage = messages.first?.zim
        config.reverse = true
        
        zim?.queryHistoryMessage(by: conversationID, conversationType: type, config: config, callback: { [self] _, _, zimMessages, error in
            let kitMessages = zimMessages.compactMap({ ZIMKitMessage(with: $0) })
            for kitMessage in kitMessages {
                self.updateKitMessageProperties(kitMessage)
                self.updateKitMessageMediaProperties(kitMessage)
                kitMessage.info.senderUserName = userDict[kitMessage.info.senderUserID]?.name
                kitMessage.info.senderUserAvatarUrl = userDict[kitMessage.info.senderUserID]?.avatarUrl
            }
            self.messageList.add(kitMessages, isNewMessage: false)
            
            callback?(error)
            if isCallbackListChanged == false { return }
            for delegate in self.delegates.allObjects {
                delegate.onHistoryMessageLoaded?(conversationID, type: type, messages: kitMessages)
            }
        })
    }
    
    func sendTextMessage(_ text: String,
                         to conversationID: String,
                         type: ZIMConversationType,
                         conversationName:String = "",
                         callback: MessageSentCallback? = nil) {
        
        var conversationName = conversationName
        if conversationName.isEmpty {
            conversationName = self.localUser?.name ?? ""
        }
        
        let message = ZIMTextMessage(message: text)
        
        var kitMessage = ZIMKitMessage(with: message)
        for delegate in delegates.allObjects {
            if let method = delegate.onMessagePreSending {
                guard let msg = method(kitMessage) else { return }
                kitMessage = msg
            }
        }
        kitMessage.info.senderUserName = localUser?.name
        kitMessage.info.senderUserAvatarUrl = localUser?.avatarUrl
        
        let config = ZIMMessageSendConfig()
        let notification = ZIMMessageSendNotification()
        notification.onMessageAttached = { message in
            if message.sentStatus != .sendFailed {
                let message = ZIMKitMessage(with: message)
                self.messageList.add([message])
                for delegate in self.delegates.allObjects {
                    delegate.onMessageSentStatusChanged?(message)
                }
            }
        }
        let pushConfig: ZIMPushConfig = ZIMPushConfig()
        pushConfig.title = conversationName
        pushConfig.content = text
        pushConfig.payload = ""
        pushConfig.resourcesID = self.config?.callPluginConfig?.resourceID ?? ""
        
        let dict:[String:String] = ["conversationID":(type == .peer) ?  localUser?.id ?? "": conversationID,"conversationType":String(describing: type.rawValue)]
        
        if let jsonString = zimKit_convertDictToString(dict: dict as [String :AnyObject]) {
            pushConfig.payload = jsonString
        }
        
        config.pushConfig = pushConfig
        zim?.sendMessage(message, toConversationID: conversationID, conversationType: type, config: config, notification: notification, callback: { message, error in
            let msg = self.messageList.get(with: message)
            msg.update(with: message)
            for delegate in self.delegates.allObjects {
                delegate.onMessageSentStatusChanged?(msg)
            }
            callback?(error)
        })
    }
    
    func sendCombineMessage(conversationID:String,
                            type:ZIMConversationType,
                            content:String,
                            conversationName:String = "",
                            combineTitle:String,
                            messageList:[ZIMKitMessage],
                            callback: sendCombineMessageCallback? = nil) {
        
        let conversationList = messageList.compactMap{ $0.zim }
        
        let config = ZIMMessageSendConfig()
        
        let notification = ZIMMessageSendNotification()
        notification.onMessageAttached = { message in
            if message.sentStatus != .sendFailed {
                let message = ZIMKitMessage(with: message)
                self.messageList.add([message])
                for delegate in self.delegates.allObjects {
                    delegate.onMessageSentStatusChanged?(message)
                }
            }
        }
        let pushConfig: ZIMPushConfig = ZIMPushConfig()
        pushConfig.title = conversationName
        pushConfig.content = content
        pushConfig.payload = ""
        pushConfig.resourcesID = self.config?.callPluginConfig?.resourceID ?? ""
        
        let dict:[String:String] = ["conversationID":(type == .peer) ?  localUser?.id ?? "": conversationID,"conversationType":String(describing: type.rawValue)]
        
        if let jsonString = zimKit_convertDictToString(dict: dict as [String :AnyObject]) {
            pushConfig.payload = jsonString
        }
        
        config.pushConfig = pushConfig
        
        let combineMessage:ZIMCombineMessage = ZIMCombineMessage()
        combineMessage.title = combineTitle
        combineMessage.summary = content
        combineMessage.messageList = conversationList
//        combineMessage.extendedData = extendedData
        zim?.sendMessage(combineMessage, toConversationID: conversationID, conversationType: type, config: config, notification: notification, callback: { message, errorInfo in
            let msg = self.messageList.get(with: message)
            msg.update(with: message)
            for delegate in self.delegates.allObjects {
                delegate.onMessageSentStatusChanged?(msg)
            }
            callback?(errorInfo)
        })
    }
    
    func sendImageMessage(_ imagePath: String,
                          to conversationID: String,
                          type: ZIMConversationType,
                          conversationName:String = "",
                          callback: MessageSentCallback? = nil) {
        
        let imageMessage = createMessage(content: imagePath, messageType: .image, conversationID: conversationID, type: type)
        
        sendMediaMessage(imageMessage as! ZIMImageMessage,
                         to: conversationID,
                         type: type,
                         conversationName: conversationName,
                         callback: callback)
    }
    
    func sendAudioMessage(_ audioPath: String,
                          duration: UInt32 = 0,
                          to conversationID: String,
                          type: ZIMConversationType,
                          conversationName:String = "",
                          callback: MessageSentCallback? = nil) {
        let audioMessage = createMessage(content:audioPath, messageType: .audio, conversationID: conversationID, type: type, duration: duration)
        sendMediaMessage(audioMessage as! ZIMAudioMessage, to: conversationID, type: type, conversationName: conversationName,callback: callback)
    }
    
    func sendVideoMessage(_ videoPath: String,
                          duration: UInt32 = 0,
                          to conversationID: String,
                          type: ZIMConversationType,
                          conversationName:String = "",
                          firstFrameDownloadUrl:String = "",
                          callback: MessageSentCallback? = nil) {
        let videoMessage = createMessage(content: videoPath, messageType: .video, conversationID: conversationID, type: type,firstFrameDownloadUrl: firstFrameDownloadUrl)
        sendMediaMessage(videoMessage as! ZIMVideoMessage, to: conversationID, type: type, conversationName: conversationName,callback: callback)
    }
    
    func sendFileMessage(_ filePath: String,
                         to conversationID: String,
                         type: ZIMConversationType,
                         conversationName:String = "",
                         fileName:String = "",
                         callback: MessageSentCallback? = nil) {
        
        let fileMessage = createMessage(content: filePath, messageType: .file, conversationID: conversationID, type: type,fileName: fileName)
        sendMediaMessage(fileMessage as! ZIMFileMessage, to: conversationID, type: type, conversationName: conversationName,callback: callback)
    }
    
    private func sendMediaMessage(_ message: ZIMMediaMessage,
                                  to conversationID: String,
                                  type: ZIMConversationType,
                                  conversationName:String = "",
                                  callback: MessageSentCallback? = nil) {
        
        var conversationName = conversationName
        if conversationName.isEmpty {
            conversationName = self.localUser?.name ?? ""
        }
        
        var kitMessage = ZIMKitMessage(with: message)
        kitMessage.info.senderUserName = localUser?.name
        kitMessage.info.senderUserAvatarUrl = localUser?.avatarUrl
        
        for delegate in delegates.allObjects {
            if let method = delegate.onMessagePreSending {
                guard let msg = method(kitMessage) else { return }
                kitMessage = msg
            }
        }
        
        let config = ZIMMessageSendConfig()
        let pushConfig: ZIMPushConfig = ZIMPushConfig()
        pushConfig.title = conversationName
        pushConfig.content = message.fileLocalPath
        pushConfig.payload = ""
        pushConfig.resourcesID = self.config?.callPluginConfig?.resourceID ?? ""
        
        let dict:[String:String] = ["conversationID":(type == .peer) ?  localUser?.id ?? "": conversationID,"conversationType":String(describing: type.rawValue)]
        
        if let jsonString = zimKit_convertDictToString(dict: dict as [String :AnyObject]) {
            pushConfig.payload = jsonString
        }
        
        config.pushConfig = pushConfig
        
        let notification = ZIMMediaMessageSendNotification()
        notification.onMessageAttached = { message in
            if message.sentStatus != .sendFailed {
                let message = ZIMKitMessage(with: message)
                self.updateKitMessageMediaProperties(message)
                self.messageList.add([message])
                for delegate in self.delegates.allObjects {
                    delegate.onMessageSentStatusChanged?(message)
                }
            }
        }
        notification.onMediaUploadingProgress = { message, currentSize, totalSize in
            let message = self.messageList.get(with: message)
            message.updateUploadProgress(currentSize: currentSize, totalSize: totalSize)
            //      let isFinished: Bool = currentSize == totalSize
            for delegate in self.delegates.allObjects {
                delegate.onMediaMessageUploadingProgressUpdated?(message, uploadProgress: Double(currentSize) / Double(totalSize))
            }
        }
        zim?.sendMediaMessage(message,
                              toConversationID: conversationID,
                              conversationType: type,
                              config: config,
                              notification: notification,
                              callback: { message, error in
            let msg = self.messageList.get(with: message)
            msg.update(with: message)
            for delegate in self.delegates.allObjects {
                delegate.onMessageSentStatusChanged?(msg)
            }
            callback?(error)
            
            if error.code != .ZIMErrorCodeSuccess { return }
            if let message = msg.zim as? ZIMImageMessage {
                if message.fileLocalPath.count > 0 {
                    try? FileManager.default.removeItem(atPath: message.fileLocalPath)
                }
            }
        })
    }
    
    
    func revokeMessage(_ message: ZIMKitMessage,
                       config: ZIMMessageRevokeConfig,
                       callback: revokeMessageCallback? = nil) {
        guard let zimMessage = message.zim else {
            let error = ZIMError()
            error.code = .ZIMErrorCodeFailed
            callback?(error)
            return
        }
        
        let revokeExtendedData:[String:String] = ["revokeUserName":self.localUser?.name ?? ""]
        
        if let jsonString = zimKit_convertDictToString(dict: revokeExtendedData as [String:AnyObject]){
            config.revokeExtendedData = jsonString
        }
        self.messageList.delete(message.info.conversationID, type: message.info.conversationType)
        zim?.revokeMessage(zimMessage, config: config, callback: { message, errorInfo in
            callback?(errorInfo)
        })
    }
    
    func downloadMediaFile(with message: ZIMKitMessage,
                           _ chatRecord:Bool = false,
                           callback: DownloadMediaFileCallback? = nil) {
        guard let zimMessage = message.zim as? ZIMMediaMessage else {
            let error = ZIMError()
            error.code = .ZIMErrorCodeFailed
            callback?(error)
            return
        }
        zim?.downloadMediaFile(with: zimMessage, fileType: .originalFile, progress: { msg, currentSize, totalSize in
            if chatRecord == false {
                let message = self.messageList.get(with: msg)
                message.updateDownloadProgress(currentSize: currentSize, totalSize: totalSize)
                
                for delegate in self.delegates.allObjects {
                    delegate.onMediaMessageDownloadingProgressUpdated?(message, isFinished:false)
                }
            }
        }, callback: { message, error in
            let isFinished: Bool = error.code == .ZIMErrorCodeSuccess
            if chatRecord == false {
                let msg = self.messageList.get(with: message)
                msg.update(with: message)
                for delegate in self.delegates.allObjects {
                    delegate.onMediaMessageDownloadingProgressUpdated?(msg, isFinished: isFinished)
                }
            } else {
                for delegate in self.delegates.allObjects {
                    delegate.onMediaMessageDownloadCompleteUpdated?(ZIMKitMessage(with: message), isFinished: isFinished)
                }
            }
            callback?(error)
        })
    }
    
    func deleteMessage(_ messages: [ZIMKitMessage],
                       callback: DeleteMessageCallback? = nil) {
        
        if messages.count == 0 {
            let error = ZIMError()
            error.code = .ZIMErrorCodeFailed
            callback?(error)
            return
        }
        
        let zimMessages = messages.compactMap({ $0.zim })
        let config = ZIMMessageDeleteConfig()
        let type = messages.first!.info.conversationType
        let conversationID = messages.first!.info.conversationID
        
        self.messageList.delete(messages)
        for delete in delegates.allObjects {
            delete.onMessageDeleted?(conversationID, type: type, messages: messages)
        }
        
        zim?.deleteMessages(zimMessages, conversationID: conversationID, conversationType: type, config: config, callback: { _, _, error in
            callback?(error)
            
            if error.code != .ZIMErrorCodeSuccess { return }
            for message in messages {
                if FileManager.default.fileExists(atPath: message.fileLocalPath) {
                    try? FileManager.default.removeItem(atPath: message.fileLocalPath)
                }
                
                if message.type == .image {
                    // remove image from cache.
                    ImageCache.removeCache(for: message.imageContent.thumbnailDownloadUrl)
                    ImageCache.removeCache(for: message.imageContent.largeImageDownloadUrl)
                    ImageCache.removeCache(for: message.imageContent.fileLocalPath)
                } else if message.type == .video {
                    ImageCache.removeCache(for: message.videoContent.firstFrameDownloadUrl)
                    ImageCache.removeCache(for: message.videoContent.firstFrameLocalPath)
                    if FileManager.default.fileExists(atPath: message.videoContent.firstFrameLocalPath) {
                        try? FileManager.default.removeItem(atPath: message.videoContent.firstFrameLocalPath)
                    }
                }
            }
        })
    }
    
    func insertMessageToLocalDB(_ message: ZIMKitMessage,
                                from senderUserID: String?,
                                to conversationID: String,
                                type: ZIMConversationType,
                                callback: InsertMessageCallback? = nil) {
        var userID:String = senderUserID ?? ""
        if userID.count  <= 0 {
            userID = self.localUser?.id ?? ""
        }
        message.info.conversationID = conversationID
        zim?.insertMessageToLocalDB(message.zim!, conversationID: conversationID, conversationType: type, senderUserID: userID, callback: { zimMessage, errorInfo in
            let zimKitMessage = ZIMKitMessage(with: zimMessage)
            self.messageList.add([zimKitMessage])
            callback?(ZIMKitMessage(with: zimMessage),errorInfo)
            
            for delegate in self.delegates.allObjects {
                delegate.onMessageSentStatusChanged?(ZIMKitMessage(with: zimMessage))
            }
        })
    }
    
    func replyMessage(_ messageType:ZIMMessageType,
                      originMessage:ZIMKitMessage,
                      conversationName:String,
                      content:String,
                      conversationID:String,
                      type: ZIMConversationType,
                      duration: UInt32 = 0,
                      firstFrameDownloadUrl:String = "",
                      fileName:String = "",
                      callback: replyMessageCallback? = nil) {
        
        let config = ZIMMessageSendConfig()
        let notification = ZIMMessageSendNotification()
        notification.onMessageAttached = { message in
            if message.sentStatus != .sendFailed {
                let message = ZIMKitMessage(with: message)
                message.info.senderUserName = self.localUser?.name
                self.messageList.add([message])
                for delegate in self.delegates.allObjects {
                    delegate.onMessageSentStatusChanged?(message)
                }
            }
        }
        
        notification.onMediaUploadingProgress = { message, currentSize, totalSize in
            let message = self.messageList.get(with: message)
            message.updateUploadProgress(currentSize: currentSize, totalSize: totalSize)
            //      let isFinished: Bool = currentSize == totalSize
            for delegate in self.delegates.allObjects {
                delegate.onMediaMessageUploadingProgressUpdated?(message, uploadProgress: Double(currentSize) / Double(totalSize))
            }
        }
        
        let pushConfig: ZIMPushConfig = ZIMPushConfig()
        pushConfig.title = conversationName
        pushConfig.content = content
        pushConfig.payload = ""
        pushConfig.resourcesID = self.config?.callPluginConfig?.resourceID ?? ""
        
        let dict:[String:String] = ["conversationID":(type == .peer) ?  localUser?.id ?? "": conversationID,"conversationType":String(describing: type.rawValue)]
        
        if let jsonString = zimKit_convertDictToString(dict: dict as [String :AnyObject]) {
            pushConfig.payload = jsonString
        }
        config.pushConfig = pushConfig
        
        let zimMessage = createMessage(content: content, messageType: messageType, conversationID: conversationID, type: type,duration: duration,firstFrameDownloadUrl: firstFrameDownloadUrl,fileName: fileName)
        
        zim!.replyMessage(zimMessage, toOriginalMessage: originMessage.zim!, config: config, notification: notification, callback: { message, errorInfo in
            let msg = self.messageList.get(with: message)
            msg.update(with: message)
            for delegate in self.delegates.allObjects {
                delegate.onMessageSentStatusChanged?(msg)
            }
            callback?(errorInfo)
        })
    }
    
    private func generateFilePath(_ oldPath: String,
                                  _ conversationID: String,
                                  _ conversationType: ZIMConversationType,
                                  _ messageType: ZIMMessageType) -> String {
        let oldUrl = URL(fileURLWithPath: oldPath)
        let fileName = oldUrl.lastPathComponent
        
        var filePathPrefix = ""
        switch messageType {
        case .image:
            filePathPrefix = ZIMKit.imagePath(conversationID, conversationType)
        case .audio:
            filePathPrefix = ZIMKit.audioPath(conversationID, conversationType)
        case .video:
            filePathPrefix = ZIMKit.videoPath(conversationID, conversationType)
        case .file:
            filePathPrefix = ZIMKit.filePath(conversationID, conversationType)
        default:
            break
        }
        
        var filePath = filePathPrefix + fileName
        
        /// if the file exist, rename the file.
        /// like `123.txt`, `123(1).txt`, `123(2).txt`
        var i = 0
        while FileManager.default.fileExists(atPath: filePath) {
            i += 1
            var newFileName = oldUrl.deletingPathExtension().lastPathComponent + "(\(i))"
            if oldUrl.pathExtension.count > 0 {
                newFileName += "." + oldUrl.pathExtension
            }
            filePath = filePathPrefix + newFileName
        }
        
        return filePath
    }
    
    func updateKitMessageProperties(_ message: ZIMKitMessage) {
        if message.info.conversationType == .peer {
            let user = userDict[message.info.senderUserID]
            message.info.senderUserName = user?.name
            message.info.senderUserAvatarUrl = user?.avatarUrl
        } else {
            let member = groupMemberDict.get(message.info.conversationID,
                                             message.info.senderUserID)
            message.info.senderUserName = member?.name
            message.info.senderUserAvatarUrl = member?.avatarUrl
        }
    }
    
    private func updateKitMessageMediaProperties(_ message: ZIMKitMessage) {
        if message.info.sentStatus == .sendSuccess { return }
        
        // media message
        var fileLocalPath = message.fileLocalPath
        if fileLocalPath.count > 0 &&
            !FileManager.default.fileExists(atPath: fileLocalPath) {
            
            let home = NSHomeDirectory()
            message.fileLocalPath = home + fileLocalPath[home.endIndex..<fileLocalPath.endIndex]
        }
        message.fileName = URL(fileURLWithPath: message.fileLocalPath).lastPathComponent
        let attributes = try? FileManager.default.attributesOfItem(atPath: message.fileLocalPath)
        message.fileSize = attributes?[.size] as? Int64 ?? 0
        
        fileLocalPath = message.fileLocalPath
        
        // image
        if message.type == .image &&
            fileLocalPath.count > 0 &&
            FileManager.default.fileExists(atPath: fileLocalPath) &&
            (message.imageContent.originalSize == .zero || message.imageContent.fileSize == 0) {
            
            let url = URL(fileURLWithPath: fileLocalPath)
            guard let data = try? Data(contentsOf: url) else { return }
            let image = UIImage(data: data)
            message.imageContent.originalSize = image?.size ?? .zero
            message.imageContent.fileSize = Int64(data.count)
        }
        
        // video
        if message.type == .video {
            var firstFrameLocalPath = message.videoContent.firstFrameLocalPath
            if firstFrameLocalPath.count > 0 &&
                !FileManager.default.fileExists(atPath: firstFrameLocalPath) {
                
                let home = NSHomeDirectory()
                message.videoContent.firstFrameLocalPath = home + firstFrameLocalPath[home.endIndex..<firstFrameLocalPath.endIndex]
            }
            
            firstFrameLocalPath = message.videoContent.firstFrameLocalPath
            if message.videoContent.firstFrameSize != .zero && FileManager.default.fileExists(atPath: firstFrameLocalPath) {
                return
            }
            
            let url = URL(fileURLWithPath: message.videoContent.fileLocalPath)
            let videoInfo = AVTool.getFirstFrameImageAndDuration(with: url)
            message.videoContent.firstFrameSize = videoInfo.image?.size ?? .zero
            message.videoContent.firstFrameLocalPath = url.deletingPathExtension().path + ".png"
            if !FileManager.default.fileExists(atPath: message.videoContent.firstFrameLocalPath) {
                let data = videoInfo.image?.pngData()
                try? data?.write(to: URL(fileURLWithPath: message.videoContent.firstFrameLocalPath))
            }
        }
    }
    
    func queryCombineMessageDetailByMessage(message: ZIMCombineMessage,
                                            callback: QueryCombineMessageDetailCallback? = nil) {
        zim?.queryCombineMessageDetail(by: message, callback: { combineMessage, errorInfo in
            let kitMessages = combineMessage.messageList.compactMap({ ZIMKitMessage(with: $0) })
            callback?(kitMessages,errorInfo)
        })
    }
    
    func addMessageReaction(message: ZIMKitMessage,
                            reactionType:String,
                            callback: MessageReactionAddedCallback? = nil) {
        
        zim?.addMessageReaction(reactionType, message: message.zim!, callback: { reaction, errorInfo in
            callback?(reaction,errorInfo)
        })
    }
    
    func deleteMessageReaction(message: ZIMKitMessage,
                               reactionType:String,
                               callback: MessageReactionDeletedCallback? = nil) {
        
        zim?.deleteMessageReaction(reactionType, message: message.zim!, callback: { reaction, errorInfo in
            callback?(reaction,errorInfo)
        })
    }
    
    private func createMessage(content: String,messageType: ZIMMessageType,conversationID: String, type: ZIMConversationType,duration: UInt32 = 0,firstFrameDownloadUrl:String = "",fileName:String = "") -> ZIMMessage {
        var zimMessage = ZIMMessage()
        if messageType == .text {
            zimMessage = ZIMTextMessage()
            (zimMessage as! ZIMTextMessage).message = content
        } else if messageType == .image {
            zimMessage = ZIMImageMessage()
            if !content.hasPrefix("http") {
                if !FileManager.default.fileExists(atPath: content) {
                    assert(false, "Path doesn't exist.")
                    return zimMessage
                }
                
                // transform heic to jpg.
                var imagePath = content
                let url = URL(fileURLWithPath: imagePath)
                if url.pathExtension == "heic",
                   let data = try? Data(contentsOf: url) {
                    let image = UIImage(data: data)
                    let imageData = image?.jpegData(compressionQuality: 0.8)
                    imagePath = url.deletingPathExtension().path + ".jpg"
                    FileManager.default.createFile(atPath: imagePath, contents: imageData)
                }
                
                let filePath = generateFilePath(content, conversationID, type, .image)
                try? FileManager.default.copyItem(atPath: imagePath, toPath: filePath)
                zimMessage = ZIMImageMessage(fileLocalPath: filePath)
            } else {
                (zimMessage as! ZIMImageMessage).fileDownloadUrl = content
                (zimMessage as! ZIMImageMessage).thumbnailDownloadUrl = content
            }
        } else if messageType == .audio {
            var filePath = content
            if !content.hasPrefix("http") {
                if !FileManager.default.fileExists(atPath: content) {
                    assert(false, "Path doesn't exist.")
                    return zimMessage
                }
                
                filePath = generateFilePath(content, conversationID, type, .audio)
                try? FileManager.default.copyItem(atPath: content, toPath: filePath)
            }
            
            
            var audioDuration: UInt32 = duration
            if audioDuration == 0 {
                audioDuration = UInt32(AVTool.getDurationOfMediaFile(content))
            }
            
            var audioMessage = ZIMAudioMessage(fileLocalPath: filePath, audioDuration: audioDuration)
            if content.hasPrefix("http") {
                audioMessage = ZIMAudioMessage()
                audioMessage.fileDownloadUrl = content
                audioMessage.audioDuration = audioDuration
            }
            zimMessage = audioMessage
        } else if messageType == .video {
            var videoMessage = ZIMVideoMessage()
            if !content.hasPrefix("http") {
                if !FileManager.default.fileExists(atPath: content) {
                    assert(false, "Path doesn't exist.")
                    return zimMessage
                }
                
                let filePath = generateFilePath(content, conversationID, type, .video)
                try? FileManager.default.copyItem(atPath: content, toPath: filePath)
                
                var videoDuration: UInt32 = duration
                if videoDuration == 0 {
                    videoDuration = UInt32(AVTool.getDurationOfMediaFile(content))
                }
                videoMessage = ZIMVideoMessage(fileLocalPath: filePath, videoDuration: videoDuration)
            } else {
                videoMessage.fileDownloadUrl = content
                videoMessage.videoFirstFrameDownloadUrl = firstFrameDownloadUrl
                videoMessage.videoDuration = duration
            }
            zimMessage = videoMessage
        } else if messageType == .file {
            var fileMessage = ZIMFileMessage()
            if !content.hasPrefix("http") {
                if !FileManager.default.fileExists(atPath: content) {
                    assert(false, "Path doesn't exist.")
                    return zimMessage
                }
                
                let newFilePath = generateFilePath(content, conversationID, type, .file)
                try? FileManager.default.copyItem(atPath: content, toPath: newFilePath)
                
                fileMessage = ZIMFileMessage(fileLocalPath: newFilePath)
            } else {
                fileMessage.fileDownloadUrl = content
                fileMessage.fileName = fileName
            }
            zimMessage = fileMessage
        } else {
            
        }
        return zimMessage
    }
}
