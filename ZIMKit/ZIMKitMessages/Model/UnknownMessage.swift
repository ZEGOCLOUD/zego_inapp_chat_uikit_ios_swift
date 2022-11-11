//
//  UnknownMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/16.
//

import Foundation
import ZIM

class UnknownMessage: Message {

    var content: String = "" {
        didSet {
            setContent(content)
        }
    }
    var attributedContent = NSAttributedString(string: "")

    override init(with msg: ZIMMessage) {
        super.init(with: msg)
        type = .unknown
        content = L10n("common_message_unknown")
        setContent(content)
    }

    override var contentSize: CGSize {
        if _contentSize == .zero {
            var size = attributedContent
                .boundingRect(with: CGSize(width: MessageCell_Text_Max_Width,
                                           height: CGFloat(MAXFLOAT)),
                              options: .usesLineFragmentOrigin, context: nil).size
            if size.height < MessageCell_Default_Content_Height {
                size.height = MessageCell_Default_Content_Height
            }
            size.width += 1.0
            _contentSize = size
        }
        return _contentSize
    }
}

extension UnknownMessage {
    func setContent(_ message: String) {
        let attributedStr = NSMutableAttributedString(string: message)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.minimumLineHeight = 21.0

        let attributes: [NSAttributedString.Key : Any] = [.font : cellConfig.messageTextFont,
                                                          .paragraphStyle : paragraphStyle,
                                                          .foregroundColor: cellConfig.messageTextColor]

        attributedStr.setAttributes(attributes, range: NSRange(location: 0, length: attributedStr.length))

        attributedContent = attributedStr
    }
}
