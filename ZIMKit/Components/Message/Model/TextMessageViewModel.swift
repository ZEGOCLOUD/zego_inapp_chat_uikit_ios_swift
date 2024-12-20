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

class TextMessageViewModel: MessageViewModel {
    
    /// The attributed text of the text message.
    var attributedContent = NSAttributedString(string: "")
    
    override init(with msg: ZIMKitMessage) {
        super.init(with: msg)
        setContent(msg.textContent.content)
    }
    
    convenience init(with content: String) {
        let msg = ZIMKitMessage()
        msg.textContent.content = content
        self.init(with: msg)
    }
//    
    override var contentSize: CGSize {
        if _contentSize == .zero {
            var size = attributedContent.boundingRect(with: CGSize(width: MessageCell_Text_Max_Width,
                                                                   height: CGFloat(MAXFLOAT)),
                                                      options: .usesLineFragmentOrigin, context: nil).size
            if size.height < MessageCell_Default_Content_Height {
                size.height = MessageCell_Default_Content_Height
            }
            size.width += 1.0
            
            if ZIMKit().imKitConfig.advancedConfig != nil && ((ZIMKit().imKitConfig.advancedConfig?.keys.contains(ZIMKitAdvancedKey.showLoadingWhenSend)) != nil && message.textContent.content == "[...]") {
                size.width = 60;
            }
            
            _contentSize = size
        }
        return _contentSize
    }
}

extension TextMessageViewModel {
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
