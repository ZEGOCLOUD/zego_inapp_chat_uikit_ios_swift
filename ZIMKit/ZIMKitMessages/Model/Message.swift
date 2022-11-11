//
//  Message.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/15.
//

import Foundation
import ZIM

public typealias MessageID = Int64

let MessageCell_Time_Top = 4.0
let MessageCell_Time_Height = 16.5
let MessageCell_Time_To_Avatar = 12.0
let MessageCell_Name_Height = 15.0
let MessageCell_Name_To_Content = 2.0
let MessageCell_Bottom_Margin = 16.0
let MessageCell_Default_Content_Height = 21.0

class Message: Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs === rhs
    }

    // MARK: - Common Properties

    /// A unique identifier of the message which from server.
    let messageID: MessageID

    /// A unique identifier of the message which generated locally.
    let localMessageID: MessageID

    /// The type of Message.
    var type: MessageType = .unknown

    /// The user identifier which User sent this message.
    var senderUserID: String

    /// The conversation identifier which this message belong to.
    let conversationID: String

    /// The message direction, `.send` or `.receive`.
    var direction: ZIMMessageDirection

    /// The status of message: `.sending`, `sendSuccess` or `sendFailed`.
    var sentStatus: ZIMMessageSentStatus

    /// The type of this conversation.
    var conversationType: ConversationType

    /// The timestamp when this message sent.
    var timestamp: UInt64

    /// The order key of message.
    var orderKey: Int64

    /// The user's name of message's sender.
    var senderUsername: String?

    /// The user avatar of message's sender.
    var senderUserAvatar: String?

    var cellConfig: MessageCellConfig  = MessageCellConfig()
    var isShowTime: Bool = true
    var isShowName: Bool {
        conversationType == .group && direction == .receive
    }
    var isShowCheckBox = false
    var isSelected = false

    var cellHeight: CGFloat = 0.0
    var _contentSize: CGSize = .zero
    var contentSize: CGSize {
        CGSize(width: 0, height: 0)
    }
    var reuseIdentifier: String {
        switch type {
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
        default:
            return UnknownMessageCell.reuseId
        }
    }

    var zimMsg: ZIMMessage


    init(with msg: ZIMMessage) {
        messageID = msg.messageID
        localMessageID = msg.localMessageID
        type = getMessageType(msg.type)
        senderUserID = msg.senderUserID
        conversationID = msg.conversationID
        direction = msg.direction
        sentStatus = msg.sentStatus
        conversationType = msg.conversationType == .peer ? .peer : .group
        timestamp = msg.timestamp
        orderKey = msg.orderKey
        senderUsername = ""
        senderUserAvatar = ""
        zimMsg = msg

        // update cell config
        cellConfig.messageTextColor = msg.direction == .send ? .zim_textWhite : .zim_textBlack1
        if type == .text || type == .unknown {
            cellConfig.contentInsets = UIEdgeInsets(top: 11, left: 12, bottom: 11, right: 12)
        }
    }

    func setNeedShowTime(_ preTimestamp: UInt64?) {
        guard let preTimestamp = preTimestamp else {
            return
        }
        // only timestamp difference between current and last message is less then 5 mins
        isShowTime = (Float(timestamp) / 1000.0 - Float(preTimestamp) / 1000.0) > 5 * 60
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

func getMessageType(_ type: ZIMMessageType) -> MessageType {
    switch type {
    case .text:
        return .text
    case .image:
        return .image
    case .audio:
        return .audio
    case .video:
        return .video
    case .file:
        return .file
    default:
        return .unknown
    }
}
