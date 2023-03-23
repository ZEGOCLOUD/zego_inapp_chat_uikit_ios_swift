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
        default:
            shortStr = L10n("common_message_unknown")
        }
        return shortStr
    }
}
