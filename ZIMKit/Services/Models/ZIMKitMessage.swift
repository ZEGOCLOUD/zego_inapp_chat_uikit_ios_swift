//
//  ZIMKitMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/6.
//

import Foundation
import ZIM

public class MessageBaseInfo {
    public var messageID: Int64 = 0
    public var localMessageID: Int64 = 0
    public var senderUserID: String = ""
    public var conversationID: String = ""
    public var conversationType: ZIMConversationType = .peer
    public var direction: ZIMMessageDirection = .send
    public var sentStatus: ZIMMessageSentStatus = .sending
    public var timestamp: UInt64 = 0
    public var conversationSeq: Int64 = 0
    public var orderKey: Int64 = 0
    public var isUserInserted: Bool = false
    public var senderUserName: String?
    public var senderUserAvatarUrl: String?
}

public struct MediaTransferProgress {
    public let currentSize: UInt64
    public let totalSize: UInt64
    
    init(_ currentSize: UInt64, _ totalSize: UInt64) {
        self.currentSize = currentSize
        self.totalSize = totalSize
    }
    
    static let `default`: MediaTransferProgress = MediaTransferProgress(0, 1)
}

public class TextMessageContent {
    public var content: String = ""
}

public class SystemMessageContent {
    public var content: String = ""
}

public class ImageMessageContent {
    public var fileLocalPath: String = ""
    public var fileDownloadUrl: String = ""
    public var fileUID: String = ""
    public var fileName: String = ""
    public var fileSize: Int64 = 0
    
    public var thumbnailDownloadUrl: String = ""
    public var thumbnailLocalPath: String = ""
    public var largeImageDownloadUrl: String = ""
    public var largeImageLocalPath: String = ""
    public var originalSize: CGSize = .zero
    public var largeSize: CGSize = .zero
    public var thumbnailSize: CGSize = .zero
    
    public var uploadProgress: MediaTransferProgress = .default
    public var downloadProgress: MediaTransferProgress = .default
}

public class AudioMessageContent {
    public var fileLocalPath: String = ""
    public var fileDownloadUrl: String = ""
    public var fileUID: String = ""
    public var fileName: String = ""
    public var fileSize: Int64 = 0
    
    public var duration: UInt32 = 0
    
    public var uploadProgress: MediaTransferProgress = .default
    public var downloadProgress: MediaTransferProgress = .default
}

public class VideoMessageContent {
    public var fileLocalPath: String = ""
    public var fileDownloadUrl: String = ""
    public var fileUID: String = ""
    public var fileName: String = ""
    public var fileSize: Int64 = 0
    
    public var duration: UInt32 = 0
    public var firstFrameDownloadUrl: String = ""
    public var firstFrameLocalPath: String = ""
    public var firstFrameSize: CGSize = .zero
    
    public var uploadProgress: MediaTransferProgress = .default
    public var downloadProgress: MediaTransferProgress = .default
}

public class FileMessageContent {
    public var fileLocalPath: String = ""
    public var fileDownloadUrl: String = ""
    public var fileUID: String = ""
    public var fileName: String = ""
    public var fileSize: Int64 = 0
    
    public var uploadProgress: MediaTransferProgress = .default
    public var downloadProgress: MediaTransferProgress = .default
}

final public class ZIMKitMessage: NSObject {
    var zim: ZIMMessage? = nil
    
    public var type: ZIMMessageType = .unknown
    
    public let info: MessageBaseInfo = .init()
    public let textContent: TextMessageContent = .init()
    public let systemContent: SystemMessageContent = .init()
    public let imageContent: ImageMessageContent = .init()
    public let audioContent: AudioMessageContent = .init()
    public let videoContent: VideoMessageContent = .init()
    public let fileContent: FileMessageContent = .init()
    
    init(with zim: ZIMMessage) {
        self.zim = zim
        super.init()
        update(with: zim)
    }
    
    override init() {
        
    }
}

