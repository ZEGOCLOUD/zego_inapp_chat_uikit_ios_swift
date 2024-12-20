//
//  ZIMMessage+Extension.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/8.
//

import Foundation
import ZIM

extension ZIMKitMessage {
    public func getShortString() -> String {
        var shortStr = ""
        switch self.type {
        case .text:
            shortStr = self.textContent.content
        case .image:
            shortStr = L10n("common_message_photo")
        case .audio:
            shortStr = L10n("common_message_audio")
        case .video:
            shortStr = L10n("common_message_video")
        case .file:
            shortStr = L10n("common_message_file")
        case .revoke:
            shortStr = L10n("common_message_revoked")
        case .combine:
            shortStr = "[\(L10n("peer_message"))]"
        case .tips:
            shortStr = L10n("invite_group")
        case .custom, .system:
            shortStr = L10n("common_message_system")
            if self.zim?.type == .custom {
                let customerMessage:ZIMCustomMessage = self.zim as! ZIMCustomMessage
                if customerMessage.subType == systemMessageSubType {
                    shortStr = self.systemContent.content
                }
            }
        default:
            shortStr = L10n("common_message_unknown")
        }
        return shortStr
    }
}
