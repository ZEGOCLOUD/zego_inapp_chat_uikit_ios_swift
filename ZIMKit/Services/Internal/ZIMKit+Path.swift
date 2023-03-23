//
//  ZIMKit+Path.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/9.
//

import Foundation
import ZIM

extension ZIMKit {
    static func imagePath(_ conversationID: String, _ type: ZIMConversationType) -> String {
        let typeStr = type == .peer ? "peer" : "group"
        let path = ZIMKitCore.shared.dataPath + "/\(conversationID)_\(typeStr)" + "/image/"
        createDirectory(path)
        return path
    }

    static func audioPath(_ conversationID: String, _ type: ZIMConversationType) -> String {
        let typeStr = type == .peer ? "peer" : "group"
        let path = ZIMKitCore.shared.dataPath + "/\(conversationID)_\(typeStr)" + "/voice/"
        createDirectory(path)
        return path
    }
    
    static func videoPath(_ conversationID: String, _ type: ZIMConversationType) -> String {
        let typeStr = type == .peer ? "peer" : "group"
        let path = ZIMKitCore.shared.dataPath + "/\(conversationID)_\(typeStr)" + "/video/"
        createDirectory(path)
        return path
    }

    static func filePath(_ conversationID: String, _ type: ZIMConversationType) -> String {
        let typeStr = type == .peer ? "peer" : "group"
        let path = ZIMKitCore.shared.dataPath + "/\(conversationID)_\(typeStr)" + "/file/"
        createDirectory(path)
        return path
    }
    
    private static func createDirectory(_ path: String) {
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            } catch {
                assertionFailure("Create image directory failed.")
            }
        }
    }
}
