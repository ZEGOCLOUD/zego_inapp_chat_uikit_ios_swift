//
//  MediaMessageViewModel.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/16.
//

import Foundation
import ZIM

class MediaMessageViewModel: MessageViewModel {
    /// Returns `true` if the media message is downloading.
    
    @ZIMKitObservable var isDownloading: Bool = false
    @ZIMKitObservable var uploadProgress: CGFloat = 0.0
    
    var contentMediaSize:CGSize = CGSize(width: 0, height: 0)
    /// Returns `true` if this audio message is playing.
    var isPlayingAudio: Bool = false
    
    override init(with msg: ZIMKitMessage) {
        super.init(with: msg)
        
        let fileLocalPath = msg.fileLocalPath
        if fileLocalPath.count > 0 &&
            !FileManager.default.fileExists(atPath: fileLocalPath) {
            
            let home = NSHomeDirectory()
            msg.fileLocalPath = home + fileLocalPath[home.endIndex..<fileLocalPath.endIndex]
        }
    }
}
