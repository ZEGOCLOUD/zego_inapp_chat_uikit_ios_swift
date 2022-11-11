//
//  TextMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/15.
//

import Foundation
import ZIM
import UIKit

let MessageCell_Text_Max_Width = UIScreen.main.bounds.width - 150.0

class TextMessage: Message {

    /// The content of the text message.
    var content: String = "" {
        didSet {
            setContent(content)
        }
    }

    /// The attributed text of the text message.
    var attributedContent = NSAttributedString(string: "")

    override init(with msg: ZIMMessage) {
        super.init(with: msg)
        guard let msg = msg as? ZIMTextMessage else { return }
        content = msg.message
        setContent(msg.message)
    }

    convenience init(with content: String) {
        let zimMsg = ZIMTextMessage()
        zimMsg.message = content
        self.init(with: zimMsg)
    }

    override var contentSize: CGSize {
        if _contentSize == .zero {
            var size = attributedContent.boundingRect(with: CGSize(width: MessageCell_Text_Max_Width,
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

extension TextMessage {
    func setContent(_ message: String) {
        let attributedStr = NSMutableAttributedString(string: message)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.minimumLineHeight = 21.0

        let attributes: [NSAttributedString.Key : Any] = [.font : cellConfig.messageTextFont,
                                                          .paragraphStyle : paragraphStyle,
                                                          .foregroundColor : cellConfig.messageTextColor]

        attributedStr.setAttributes(attributes, range: NSRange(location: 0, length: attributedStr.length))

        attributedContent = attributedStr
    }
}
