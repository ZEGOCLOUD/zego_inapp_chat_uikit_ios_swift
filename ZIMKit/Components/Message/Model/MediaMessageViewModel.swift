//
//  MediaMessageViewModel.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/16.
//

import Foundation
import ZIM

class MediaMessageViewModel: MessageViewModel {

    @ZIMKitObservable var isDownloading: Bool = false
    @ZIMKitObservable var uploadProgress: CGFloat = 0.0
  
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
