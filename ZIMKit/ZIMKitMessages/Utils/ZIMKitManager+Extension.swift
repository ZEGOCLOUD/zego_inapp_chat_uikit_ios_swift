//
//  ZIMKitManager+Extension.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/10/26.
//

import Foundation

extension ZIMKitManager {
    var imagePath: String {
        let path = dataPath + "/image/"
        createDirectory(path)
        return path
    }

    var audioPath: String {
        let path = dataPath + "/voice/"
        createDirectory(path)
        return path
    }

    var videoPath: String {
        let path = dataPath + "/video/"
        createDirectory(path)
        return path
    }

    var filePath: String {
        let path = dataPath + "/file/"
        createDirectory(path)
        return path
    }

    private func createDirectory(_ path: String) {
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            } catch {
                assertionFailure("Create image directory failed.")
            }
        }
    }
}
