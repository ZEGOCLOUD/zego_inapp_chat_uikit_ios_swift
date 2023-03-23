//
//  MessageFactory.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/17.
//

import Foundation
import ZIM

class MessageViewModelFactory {
    static func createMessage(with msg: ZIMKitMessage) -> MessageViewModel {
        switch msg.type {
        case .text:
            return TextMessageViewModel(with: msg)
        case .image:
            return ImageMessageViewModel(with: msg)
        case .audio:
            return AudioMessageViewModel(with: msg)
        case .video:
            return VideoMessageViewModel(with: msg)
        case .file:
            return FileMessageViewModel(with: msg)
        default:
            return UnknownMessageViewModel(with: msg)
        }
    }
}
