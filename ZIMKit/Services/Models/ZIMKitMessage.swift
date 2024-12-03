//
//  ZIMKitMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/6.
//

import Foundation
import ZIM

public class MessageBaseInfo: NSObject {
    @objc public var messageID: Int64 = 0
    @objc public var cbInnerID: String = ""
    @objc public var localMessageID: Int64 = 0
    @objc public var senderUserID: String = ""
    @objc public var conversationID: String = ""
    @objc public var conversationType: ZIMConversationType = .peer
    @objc public var direction: ZIMMessageDirection = .send
    @objc public var sentStatus: ZIMMessageSentStatus = .sending
    @objc public var timestamp: UInt64 = 0
    @objc public var conversationSeq: Int64 = 0
    @objc public var orderKey: Int64 = 0
    @objc public var isUserInserted: Bool = false
    @objc public var senderUserName: String?
    @objc public var senderUserAvatarUrl: String?
}

public class MediaTransferProgress: NSObject {
    @objc public let currentSize: UInt64
    @objc public let totalSize: UInt64
    
    init(_ currentSize: UInt64, _ totalSize: UInt64) {
        self.currentSize = currentSize
        self.totalSize = totalSize
    }
    
    static let `default`: MediaTransferProgress = MediaTransferProgress(0, 1)
}

public class TextMessageContent: NSObject {
    @objc public var content: String = ""
}

public class SystemMessageContent: NSObject {
    @objc public var content: String = ""
}

public class ImageMessageContent: NSObject {
    @objc public var fileLocalPath: String = ""
    @objc public var fileDownloadUrl: String = ""
    @objc public var fileUID: String = ""
    @objc public var fileName: String = ""
    @objc public var fileSize: Int64 = 0
    
    @objc public var thumbnailDownloadUrl: String = ""
    @objc public var thumbnailLocalPath: String = ""
    @objc public var largeImageDownloadUrl: String = ""
    @objc public var largeImageLocalPath: String = ""
    @objc public var originalSize: CGSize = .zero
    @objc public var largeSize: CGSize = .zero
    @objc public var thumbnailSize: CGSize = .zero
    
    @objc public var uploadProgress: MediaTransferProgress = .default
    @objc public var downloadProgress: MediaTransferProgress = .default
}

public class AudioMessageContent: NSObject {
    @objc public var fileLocalPath: String = ""
    @objc public var fileDownloadUrl: String = ""
    @objc public var fileUID: String = ""
    @objc public var fileName: String = ""
    @objc public var fileSize: Int64 = 0
    
    @objc public var duration: UInt32 = 0
    
    @objc public var uploadProgress: MediaTransferProgress = .default
    @objc public var downloadProgress: MediaTransferProgress = .default
}

public class VideoMessageContent: NSObject {
    @objc public var fileLocalPath: String = ""
    @objc public var fileDownloadUrl: String = ""
    @objc public var fileUID: String = ""
    @objc public var fileName: String = ""
    @objc public var fileSize: Int64 = 0
    
    @objc public var duration: UInt32 = 0
    @objc public var firstFrameDownloadUrl: String = ""
    @objc public var firstFrameLocalPath: String = ""
    @objc public var firstFrameSize: CGSize = .zero
    
    @objc public var uploadProgress: MediaTransferProgress = .default
    @objc public var downloadProgress: MediaTransferProgress = .default
}

public class FileMessageContent: NSObject {
    @objc public var fileLocalPath: String = ""
    @objc public var fileDownloadUrl: String = ""
    @objc public var fileUID: String = ""
    @objc public var fileName: String = ""
    @objc public var fileSize: Int64 = 0
    
    @objc public var uploadProgress: MediaTransferProgress = .default
    @objc public var downloadProgress: MediaTransferProgress = .default
}

final public class ZIMKitMessage: NSObject {
    var zim: ZIMMessage? = nil
    
    @objc public var type: ZIMMessageType = .unknown
    
    @objc public let info: MessageBaseInfo = .init()
    @objc public let textContent: TextMessageContent = .init()
    @objc public let systemContent: SystemMessageContent = .init()
    @objc public let imageContent: ImageMessageContent = .init()
    @objc public let audioContent: AudioMessageContent = .init()
    @objc public let videoContent: VideoMessageContent = .init()
    @objc public let fileContent: FileMessageContent = .init()
    @objc public var revokeExtendedData :String = ""
    @objc public var replyMessage :ZIMMessageLiteInfo?
    @objc public var reactions = [ZIMMessageReaction]()
    init(with zim: ZIMMessage) {
        self.zim = zim
        super.init()
        update(with: zim)
    }
    
    override init() {
        
    }
}

