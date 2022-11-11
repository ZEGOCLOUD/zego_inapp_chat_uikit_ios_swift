//
//  AudioMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/17.
//

import Foundation
import ZIM

class AudioMessage: MediaMessage {

    /// The duration of audio.
    var duration: UInt32 = 0

    /// Returns `true` if this audio message is playing.
    var isPlayingAudio: Bool = false

    override init(with msg: ZIMMessage) {
        super.init(with: msg)
        guard let msg = msg as? ZIMAudioMessage else { return }
        duration = msg.audioDuration
        cellConfig.contentInsets = .zero
    }

    convenience init(with fileLocalPath: String, duration: UInt32) {
        let msg = ZIMAudioMessage()
        msg.fileLocalPath = fileLocalPath
        msg.audioDuration = duration
        self.init(with: msg)
    }

    override var contentSize: CGSize {
        let maxW = UIScreen.main.bounds.width * 0.4
        let minW = 70.0
        var w = minW + (maxW - minW) * Double(duration) / 60.0
        w = min(w, maxW)
        return CGSize(width: w, height: 43)
    }
}
