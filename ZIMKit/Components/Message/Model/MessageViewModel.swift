//
//  Message.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/15.
//

import Foundation
import ZIM

let MessageCell_Time_Top = 4.0
let MessageCell_Time_Height = 16.5
let MessageCell_Time_To_Avatar = 12.0
let MessageCell_Name_Height = 15.0
let MessageCell_Name_To_Content = 2.0
let MessageCell_Bottom_Margin = 16.0
let MessageCell_Default_Content_Height = 21.0

class MessageViewModel: Equatable {
    static func == (lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
        lhs === rhs
    }
    
    var cellConfig: MessageCellConfig  = MessageCellConfig()
    var isShowTime: Bool = true
    var isShowName: Bool {
      message.info.conversationType == .group && message.info.direction == .receive && message.type != .revoke
    }
    var isShowCheckBox = false
    var isSelected = false

    var cellHeight: CGFloat = 0.0
    var _contentSize: CGSize = .zero
    var contentSize: CGSize {
        CGSize(width: 0, height: 0)
    }
    var reuseIdentifier: String {
        switch message.type {
        case .text:
            return TextMessageCell.reuseId
        case .image:
            return ImageMessageCell.reuseId
        case .system:
            return SystemMessageCell.reuseId
        case .audio:
            return AudioMessageCell.reuseId
        case .video:
            return VideoMessageCell.reuseId
        case .file:
            return FileMessageCell.reuseId
        case .revoke:
            return RevokeMessageCell.reuseId
        default:
            return UnknownMessageCell.reuseId
        }
    }

    var message: ZIMKitMessage


    init(with msg: ZIMKitMessage) {
        message = msg

        // update cell config
        cellConfig.messageTextColor = msg.info.direction == .send ? .zim_textWhite : .zim_textBlack1
        if message.type == .text || message.type == .unknown {
            cellConfig.contentInsets = UIEdgeInsets(top: 11, left: 12, bottom: 11, right: 12)
        }
    }

    func setNeedShowTime(_ preTimestamp: UInt64?) {
        guard let preTimestamp = preTimestamp else {
            return
        }
        // only timestamp difference between current and last message is less then 5 mins
        isShowTime = (Float(message.info.timestamp) / 1000.0 - Float(preTimestamp) / 1000.0) > 5 * 60
    }

    func setCellHeight() {
        var height = 0.0

        if isShowTime {
            height += MessageCell_Time_Top
            height += MessageCell_Time_Height
            height += MessageCell_Time_To_Avatar
        }

        if isShowName {
            height += MessageCell_Name_Height
            height += MessageCell_Name_To_Content
        }

        height += contentSize.height

        height += cellConfig.contentInsets.top + cellConfig.contentInsets.bottom

        height += MessageCell_Bottom_Margin

        cellHeight = height
    }

    func reSetCellHeight() {
        cellHeight = 0.0
        _contentSize = .zero
        setCellHeight()
    }
}
