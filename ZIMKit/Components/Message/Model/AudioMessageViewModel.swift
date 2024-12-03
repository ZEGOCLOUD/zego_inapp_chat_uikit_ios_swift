//
//  AudioMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/17.
//

import Foundation
import ZIM

class AudioMessageViewModel: MediaMessageViewModel {
    
    override init(with msg: ZIMKitMessage) {
        super.init(with: msg)
        cellConfig.contentInsets = .zero
    }
    
    convenience init(with fileLocalPath: String, duration: UInt32) {
        let msg = ZIMKitMessage()
        msg.audioContent.fileLocalPath = fileLocalPath
        msg.audioContent.duration = duration
        self.init(with: msg)
    }
    
    override var contentSize: CGSize {
        let maxW = UIScreen.main.bounds.width * 0.4
        let minW = 70.0
        var w = minW + (maxW - minW) * Double(message.audioContent.duration) / 60.0
        w = min(w, maxW)
        contentMediaSize = CGSizeMake(w, 43)
        if message.reactions.count.isEmpty {
            return CGSize(width: w, height: 43)
        } else {
            return CGSize(width: w, height: 63)
        }
    }
}
