//
//  MessageFactory.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/17.
//

import Foundation
import ZIM

class MessageFactory {
    static func createMessage(with msg: ZIMMessage) -> Message {
        switch msg.type {
        case .text:
            return TextMessage(with: msg)
        case .image:
            return ImageMessage(with: msg)
        case .audio:
            return AudioMessage(with: msg)
        case .video:
            return VideoMessage(with: msg)
        case .file:
            return FileMessage(with: msg)
        default:
            return UnknownMessage(with: msg)
        }
    }
}
