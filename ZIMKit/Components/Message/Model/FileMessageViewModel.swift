//
//  FileMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/17.
//

import Foundation
import ZIM

class FileMessageViewModel: MediaMessageViewModel {
    
    override init(with msg: ZIMKitMessage) {
        super.init(with: msg)
    }
    
    convenience init(with fileLocalPath: String) {
        let msg = ZIMKitMessage()
        msg.fileContent.fileLocalPath = fileLocalPath
        self.init(with: msg)
    }

    override var contentSize: CGSize {
        CGSize(width: 234, height: 62)
    }
}
