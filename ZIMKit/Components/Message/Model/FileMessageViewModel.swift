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
        contentMediaSize = CGSize(width: 234, height: 62)
        _contentSize = contentMediaSize
        if message.reactions.count.isEmpty {
           
        } else {
            if message.replyMessage == nil {
                _contentSize.width += 24
                _contentSize.height += 20
            }
        }
        return _contentSize
    }
}
