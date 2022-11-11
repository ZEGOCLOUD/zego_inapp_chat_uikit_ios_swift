//
//  MediaMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/16.
//

import Foundation
import ZIM

class MediaMessage: Message {

    /// The media file local path of the message.
    @Observable var fileLocalPath: String = "" {
        didSet {
            let msg = zimMsg as? ZIMMediaMessage
            msg?.fileLocalPath = fileLocalPath
        }
    }

    /// The media file download url of the message.
    var fileDownloadUrl: String = ""

    /// The unique identifier of the media message.
    var fileUID: String = ""

    /// The file name of the media message.
    var fileName: String = ""

    /// The file size of the media message.
    var fileSize: Int64 = 0

    /// Returns `true` if the media message is downloading.
    @Observable var isDownloading: Bool = false

    override init(with msg: ZIMMessage) {
        super.init(with: msg)
        guard let msg = msg as? ZIMMediaMessage else { return }
        fileLocalPath = msg.fileLocalPath
        fileDownloadUrl = msg.fileDownloadUrl
        fileUID = msg.fileUID
        fileName = msg.fileName
        fileSize = msg.fileSize
        if fileLocalPath.count > 0 &&
            !FileManager.default.fileExists(atPath: fileLocalPath) &&
            type != .image {
            // image will use ImageCache data, not the file.
            let home = NSHomeDirectory()
            fileLocalPath = home + fileLocalPath[home.endIndex..<fileLocalPath.endIndex]
        }
    }
}
