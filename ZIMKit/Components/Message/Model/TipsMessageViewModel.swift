//
//  TipsMessageCell.swift
//  ZIMKit
//
//  Created by zego on 2024/8/23.
//

import UIKit
import ZIM

let MessageCell_Tip_Max_Width = UIScreen.main.bounds.width - 100

class TipsMessageViewModel: MessageViewModel {
    
    var attributedContent = NSAttributedString(string: "")
    
    override init(with msg: ZIMKitMessage) {
        super.init(with: msg)
        isShowTime = false
        setContent()
    }
    
    override var contentSize: CGSize {
        if _contentSize == .zero {
            var size = attributedContent.boundingRect(with: CGSize(width: MessageCell_Tip_Max_Width,
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


extension TipsMessageViewModel {
    func setContent() {
        guard let messageZIM:ZIMTipsMessage = message.zim as? ZIMTipsMessage else {return}
        let operatedUserName = messageZIM.operatedUser.userName
        
        let contentMsg = NSMutableAttributedString(string: operatedUserName + " " + L10n("invite_group_tips_title") + " " )
        contentMsg.addAttribute(.foregroundColor, value: UIColor(hex: 0x3478FC), range: NSRange(location: 0, length: operatedUserName.count))
        contentMsg.addAttribute(.font, value: UIFont.systemFont(ofSize: 12, weight: .medium), range: NSRange(location: 0, length: contentMsg.string.count))
        
        for (index,user) in messageZIM.targetUserList.enumerated() {
            let userNameAttributed = NSMutableAttributedString(string: user.userName)
            userNameAttributed.addAttribute(.foregroundColor, value: UIColor(hex: 0x3478FC), range: NSRange(location: 0, length: userNameAttributed.length))
            
            contentMsg.append(userNameAttributed)
            if index != (messageZIM.targetUserList.count - 1) {
                contentMsg.append(NSAttributedString(string: "，"))
            }
            
        }
        let desAttributed = NSMutableAttributedString(string: " " + L10n("invite_group_tips_des"))
        contentMsg.append(desAttributed)
        
        
        // 设置行间距
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .center
        
        contentMsg.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: contentMsg.length))
        
        attributedContent = contentMsg
    }
}
