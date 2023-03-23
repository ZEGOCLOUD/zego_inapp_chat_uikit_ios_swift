//
//  AudioMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/17.
//

import Foundation
import ZIM

class AudioMessageViewModel: MediaMessageViewModel {
    
    /// Returns `true` if this audio message is playing.
    var isPlayingAudio: Bool = false

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
        return CGSize(width: w, height: 43)
    }
}
