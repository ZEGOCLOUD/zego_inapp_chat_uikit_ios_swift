//
//  SystemMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/16.
//

import Foundation
import ZIM

let MessageCell_System_Max_Width = UIScreen.main.bounds.width - 60.0

class SystemMessage: Message {

    convenience init(with content: String) {
        let msg = ZIMTextMessage()
        msg.message = content
        self.init(with: msg)
        type = .system
        cellConfig.contentInsets = .zero
        self.content = content
        setContent(content)
    }

    var content: String = "" {
        didSet {
            setContent(content)
        }
    }
    var attributedContent = NSAttributedString(string: "")


    override var contentSize: CGSize {
        if _contentSize == .zero {
            var size = attributedContent.boundingRect(with: CGSize(width: MessageCell_System_Max_Width,
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

extension SystemMessage {
    func setContent(_ message: String) {
        let attributedStr = NSMutableAttributedString(string: message)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.minimumLineHeight = 21.0
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 13, weight: .medium),
                                                          .paragraphStyle : paragraphStyle,
                                                          .foregroundColor: UIColor.zim_textGray2]

        attributedStr.setAttributes(attributes, range: NSRange(location: 0, length: attributedStr.length))

        attributedContent = attributedStr
    }
}
