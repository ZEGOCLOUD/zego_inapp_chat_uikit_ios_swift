//
//  CombineMessageViewModel.swift
//  ZIMKit
//
//  Created by zego on 2024/8/22.
//

import UIKit
import ZIM
let MessageCell_Combine_Max_Width = UIScreen.main.bounds.width - 150.0

class CombineMessageViewModel: MessageViewModel {
    
    var attributedContent = NSAttributedString(string: "")
    var MessageCell_Combine_Min_Width = 120.0
    var combineTitle:String = ""
    var combineContentSize:CGSize = CGSizeMake(100, 50)
    override init(with msg: ZIMKitMessage) {
        super.init(with: msg)
        setContent(msg)
    }
    
    override var contentSize: CGSize {
        if _contentSize == .zero {
            let attributedStr = NSMutableAttributedString(string: combineTitle)

            let attributes: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 15, weight: .medium),
                                                              .foregroundColor : UIColor.black]
            
            attributedStr.setAttributes(attributes, range: NSRange(location: 0, length: attributedStr.length))
            
            var titleSize = attributedStr.boundingRect(with: CGSize(width: MessageCell_Combine_Max_Width,
                                                                   height: CGFloat(MAXFLOAT)),
                                                      options: .usesLineFragmentOrigin, context: nil).size
            if titleSize.height < MessageCell_Default_Content_Height {
                titleSize.height = MessageCell_Default_Content_Height
            }
            
            titleSize.width += 34
            if titleSize.width < MessageCell_Combine_Max_Width {
                titleSize.width = MessageCell_Combine_Max_Width
            }
            
            let size = CGSize(width: max(titleSize.width, combineContentSize.width), height: titleSize.height + combineContentSize.height + 26)
            
            _contentSize = size
        }
        return _contentSize
    }
}

extension CombineMessageViewModel {
    func setContent(_ message: ZIMKitMessage) {
        var contentMessage:String = ""
        if message.zim is ZIMCombineMessage {
            let combineMessage: ZIMCombineMessage = message.zim as! ZIMCombineMessage
            contentMessage = combineMessage.summary
            combineTitle = combineMessage.title
        }
        let attributedStr = NSMutableAttributedString(string: contentMessage)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.minimumLineHeight = 18.0
        
        
        let textColor = message.info.direction == .send ? UIColor(hex: 0xFFFFFF,a: 0.7) :  UIColor(hex: 0x2A2A2A,a: 0.7)
        let attributes: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 13),
                                                          .paragraphStyle : paragraphStyle,
                                                          .foregroundColor : textColor]
        
        attributedStr.setAttributes(attributes, range: NSRange(location: 0, length: attributedStr.length))
        
        attributedContent = attributedStr
        
        let size = attributedStr.boundingRect(with: CGSize(width: MessageCell_Combine_Max_Width,
                                                               height: CGFloat(MAXFLOAT)),
                                                  options: .usesLineFragmentOrigin, context: nil).size

        
        combineContentSize = CGSizeMake(size.width, size.height+3)
    }
}
