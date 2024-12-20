//
//  ZIMKitMessage+Extension.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/6.
//

import Foundation
import ZIM

extension ZIMKitMessage {
    func update(with zim: ZIMMessage) {
        type = zim.type
        reactions = zim.reactions
//        if zim.type == .custom {
//            let customerMessage:ZIMCustomMessage = zim as! ZIMCustomMessage
//            if customerMessage.subType == systemMessageSubType {
//                type = .custom
//            }
//        }
        info.messageID = zim.messageID
        info.localMessageID = zim.localMessageID
        info.cbInnerID = zim.cbInnerID
        info.senderUserID = zim.senderUserID
        info.conversationID = zim.conversationID
        info.conversationType = zim.conversationType
        info.direction = zim.direction
        info.sentStatus = zim.sentStatus
        info.timestamp = zim.timestamp
        info.conversationSeq = zim.conversationSeq
        info.orderKey = zim.orderKey
        info.isUserInserted = zim.isUserInserted
        
        if let zim = zim as? ZIMTextMessage {
            textContent.content = zim.message
        }
        
        if let zim = zim as? ZIMCustomMessage {
            systemContent.content = zim.message
        }
        
        if let zim = zim as? ZIMCustomMessage {
            systemContent.content = zim.message
        }
        
        func f<T: Empty>(_ left: T, _ right: T) -> T.T {
            if right.isEmpty {
                return left.itself
            }
            return right.itself
        }
        
        if let zim = zim as? ZIMImageMessage {
            imageContent.fileLocalPath = f(imageContent.fileLocalPath, zim.fileLocalPath)
            imageContent.fileDownloadUrl = zim.fileDownloadUrl
            imageContent.fileUID = zim.fileUID
            imageContent.fileName = f(imageContent.fileName, zim.fileName)
            imageContent.fileSize = f(imageContent.fileSize, zim.fileSize)
            imageContent.thumbnailDownloadUrl = zim.thumbnailDownloadUrl
            imageContent.thumbnailLocalPath = f(imageContent.thumbnailLocalPath, zim.thumbnailLocalPath)
            imageContent.largeImageDownloadUrl = zim.largeImageDownloadUrl
            imageContent.largeImageLocalPath = f(imageContent.largeImageLocalPath, zim.largeImageLocalPath)
            imageContent.originalSize = f(imageContent.originalSize, zim.originalImageSize)
            imageContent.largeSize = f(imageContent.largeSize, zim.largeImageSize)
            imageContent.thumbnailSize = f(imageContent.thumbnailSize, zim.thumbnailSize)
        }
        
        if let zim = zim as? ZIMAudioMessage {
            audioContent.fileLocalPath = f(audioContent.fileLocalPath, zim.fileLocalPath)
            audioContent.fileDownloadUrl = zim.fileDownloadUrl
            audioContent.fileUID = zim.fileUID
            audioContent.fileName = f(audioContent.fileName, zim.fileName)
            audioContent.fileSize = f(audioContent.fileSize, zim.fileSize)
            audioContent.duration = f(audioContent.duration, zim.audioDuration)
        }
        
        if let zim = zim as? ZIMVideoMessage {
            videoContent.fileLocalPath = f(videoContent.fileLocalPath, zim.fileLocalPath)
            videoContent.fileDownloadUrl = zim.fileDownloadUrl
            videoContent.fileUID = zim.fileUID
            videoContent.fileName = f(videoContent.fileName, zim.fileName)
            videoContent.fileSize = f(videoContent.fileSize, zim.fileSize)
            videoContent.duration = f(videoContent.duration, zim.videoDuration)
            videoContent.firstFrameDownloadUrl = zim.videoFirstFrameDownloadUrl
            videoContent.firstFrameLocalPath = f(videoContent.firstFrameLocalPath, zim.videoFirstFrameLocalPath)
            videoContent.firstFrameSize = f(videoContent.firstFrameSize, zim.videoFirstFrameSize)
        }
        
        if let zim = zim as? ZIMFileMessage {
            fileContent.fileLocalPath = f(fileContent.fileLocalPath, zim.fileLocalPath)
            fileContent.fileDownloadUrl = zim.fileDownloadUrl
            fileContent.fileUID = zim.fileUID
            fileContent.fileName = f(fileContent.fileName, zim.fileName)
            fileContent.fileSize = f(fileContent.fileSize, zim.fileSize)
        }
      
        if type == .revoke {
          if let revokeObject = zim as? ZIMRevokeMessage {
            revokeExtendedData = revokeObject.revokeExtendedData
          }
        }
      
        if (zim.repliedInfo != nil) {
          replyMessage = zim.repliedInfo!.messageInfo
        }
    }
    
    func updateUploadProgress(currentSize: UInt64, totalSize: UInt64) {
        switch type {
        case .audio:
            audioContent.uploadProgress = .init(currentSize, totalSize)
        case .video:
            videoContent.uploadProgress = .init(currentSize, totalSize)
        case .image:
            imageContent.uploadProgress = .init(currentSize, totalSize)
        case .file:
            fileContent.uploadProgress = .init(currentSize, totalSize)
        default:
            break
        }
    }
    
    func updateDownloadProgress(currentSize: UInt64, totalSize: UInt64) {
        switch type {
        case .audio:
            audioContent.downloadProgress = .init(currentSize, totalSize)
        case .video:
            videoContent.downloadProgress = .init(currentSize, totalSize)
        case .image:
            imageContent.downloadProgress = .init(currentSize, totalSize)
        case .file:
            fileContent.downloadProgress = .init(currentSize, totalSize)
        default:
            break
        }
    }
    
    var fileLocalPath: String {
        get {
            switch type {
            case .image: return imageContent.fileLocalPath
            case .audio: return audioContent.fileLocalPath
            case .video: return videoContent.fileLocalPath
            case .file: return fileContent.fileLocalPath
            default: return ""
            }
        }
        set {
            switch type {
            case .image: imageContent.fileLocalPath = newValue
            case .audio: audioContent.fileLocalPath = newValue
            case .video: videoContent.fileLocalPath = newValue
            case .file: fileContent.fileLocalPath = newValue
            default: break
            }
        }
    }
    
    var fileDownloadUrl: String {
        switch type {
        case .image: return imageContent.fileDownloadUrl
        case .audio: return audioContent.fileDownloadUrl
        case .video: return videoContent.fileDownloadUrl
        case .file: return fileContent.fileDownloadUrl
        default: return ""
        }
    }
    
    var fileUID: String {
        switch type {
        case .image: return imageContent.fileUID
        case .audio: return audioContent.fileUID
        case .video: return videoContent.fileUID
        case .file: return fileContent.fileUID
        default: return ""
        }
    }
    
    var fileName: String {
        get {
            switch type {
            case .image: return imageContent.fileName
            case .audio: return audioContent.fileName
            case .video: return videoContent.fileName
            case .file: return fileContent.fileName
            default: return ""
            }
        }
        set {
            switch type {
            case .image: imageContent.fileName = newValue
            case .audio: audioContent.fileName = newValue
            case .video: videoContent.fileName = newValue
            case .file: fileContent.fileName = newValue
            default: break
            }
        }
    }
    
    var fileSize: Int64 {
        get {
            switch type {
            case .image: return imageContent.fileSize
            case .audio: return audioContent.fileSize
            case .video: return videoContent.fileSize
            case .file: return fileContent.fileSize
            default: return 0
            }
        }
        set {
            switch type {
            case .image: imageContent.fileSize = newValue
            case .audio: audioContent.fileSize = newValue
            case .video: videoContent.fileSize = newValue
            case .file: fileContent.fileSize = newValue
            default: break
            }
        }
    }
    
    var uploadProgress: MediaTransferProgress {
        switch type {
        case .image: return imageContent.uploadProgress
        case .audio: return audioContent.uploadProgress
        case .video: return videoContent.uploadProgress
        case .file: return fileContent.uploadProgress
        default: return .default
        }
    }
    var downloadProgress: MediaTransferProgress {
        switch type {
        case .image: return imageContent.downloadProgress
        case .audio: return audioContent.downloadProgress
        case .video: return videoContent.downloadProgress
        case .file: return fileContent.downloadProgress
        default: return .default
        }
    }
}
