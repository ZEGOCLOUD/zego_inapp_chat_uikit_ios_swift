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
        
        if msg.replyMessage != nil && msg.type != .revoke && msg.type != .custom && msg.type != .system && msg.type != .tips {
            return createReplyMessage(with: msg)
        }
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
        case .revoke:
            return RevokeMessageViewModel(with: msg)
        case .combine:
            return CombineMessageViewModel(with: msg)
        case .tips:
            return TipsMessageViewModel(with: msg)
        case .custom, .system:
            return CustomerMessageViewModel(with: msg)
        default:
            return UnknownMessageViewModel(with: msg)
        }
    }
    
    static func createReplyMessage(with msg:ZIMKitMessage) ->MessageViewModel {
        return ReplyMessageViewModel(with: msg)
    }
}
