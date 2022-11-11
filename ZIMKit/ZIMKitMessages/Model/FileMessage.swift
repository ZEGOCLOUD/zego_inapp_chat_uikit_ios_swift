//
//  FileMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/17.
//

import Foundation
import ZIM

class FileMessage: MediaMessage {
    override init(with msg: ZIMMessage) {
        super.init(with: msg)
    }

    convenience init(with fileLocalPath: String) {
        let msg = ZIMFileMessage()
        msg.fileLocalPath = fileLocalPath
        self.init(with: msg)
    }

    override var contentSize: CGSize {
        CGSize(width: 234, height: 62)
    }
}
