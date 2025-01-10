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
let MessageCell_ContainView_Margin_Left_Right = 24.0
class MessageViewModel: Equatable {
    static func == (lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
        lhs === rhs
    }
    
    var cellConfig: MessageCellConfig  = MessageCellConfig()
    var isShowTime: Bool = true
    var isShowName: Bool {
        message.info.conversationType == .group && message.info.direction == .receive && message.type != .revoke && message.type != .tips
    }
    var isShowCheckBox = false
    var isSelected = false
    var reactionUserNames = [String]()
    var cellHeight: CGFloat = 0.0
    var containerViewWidth: CGFloat = 0.0
    var reactionHeight: CGFloat = 0.0
    var _contentSize: CGSize = .zero
    var contentSize: CGSize {
        CGSize(width: 0, height: 0)
    }
    var reuseIdentifier: String {
        if message.replyMessage != nil && message.type != .revoke && message.type != .custom  && message.type != .system && message.type != .tips {
            return ReplyMessageCell.reuseId
        }
        switch message.type {
        case .text:
            return TextMessageCell.reuseId
        case .image:
            return ImageMessageCell.reuseId
        case .system:
            return CustomerMessageCell.reuseId
        case .audio:
            return AudioMessageCell.reuseId
        case .video:
            return VideoMessageCell.reuseId
        case .file:
            return FileMessageCell.reuseId
        case .revoke:
            return RevokeMessageCell.reuseId
        case .combine:
            return CombineMessageCell.reuseId
        case .tips:
            return TipsMessageCell.reuseId
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
        if message.type == .revoke || message.type == .tips || message.type == .custom || message.type == .system {
            
            
            if message.zim is ZIMCustomMessage  {
                if (message.zim as! ZIMCustomMessage).subType == systemMessageSubType {
                    isShowTime = true
                } else {
                    isShowTime = false
                }
            } else {
                isShowTime = false
            }
        }
    }
    
    func setCellHeight() {
        updateCellHeight()
        updateReactionMessageSize()
    }
    
    func updateCellHeight() {
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
    
    func updateReactionMessageSize() {
        
        if self.message.reactions.count <= 0 {
            reactionHeight = 0
            containerViewWidth = 0.0
            reactionUserNames.removeAll()
            return
        }
        
        let reactionMarginTop = 10.0
        let reactionLeftRightMargin = 50.0
        let reactionPadding:CGFloat = 5.0
        
        var userNameHeight:CGFloat = 24
        var currentWidth:CGFloat = 0
        
        let maxWidth:CGFloat = MessageCell_Text_Max_Width - MessageCell_ContainView_Margin_Left_Right + 1
        //MARK: 只计算表态消息的高度 表态距离上面视图的间距 reactionMarginTop， containerView 上下的间距再各自的model中添加了
        if reactionHeight > 0 {
            cellHeight -= (reactionHeight + reactionMarginTop)
        } else {
            updateCellHeight()
        }
        reactionHeight = 0.0
        reactionUserNames.removeAll()
        containerViewWidth = 0.0
        
        for (reactionIndex,reaction) in self.message.reactions.enumerated() {
            var userNames:String = ""

            let dispatchGroup = DispatchGroup()
            let queue = DispatchQueue(label: "com.zego.imkit.quene", attributes: .concurrent)

            for (userIndex,reactionUserInfo) in reaction.userList.enumerated() {
                var userName:String = "iOS"
                dispatchGroup.enter()
                queue.async {
                    
                    self.getUserName(userID: reactionUserInfo.userID, groupID: reaction.conversationID) { name in
                       userName = name ?? ""
                        
                        if userIndex < reaction.userList.count - 1 {
                            userNames += (userName + "，")
                        } else {
                            userNames += userName
                        }
                        dispatchGroup.leave()
                   }
   
                }
                dispatchGroup.wait()
            }
//             userNames = "Simon，Stevin，马萧萧，Simon，Stevin，Simon，Stevin，Simon，Stevin，Simon，Stevin"
            var size = userNames.boundingRect(with: CGSize(width: maxWidth , height: 15), options: .usesLineFragmentOrigin, attributes: [.font : UIFont.systemFont(ofSize: 12)], context: nil)
            if (size.width  + reactionLeftRightMargin) > maxWidth {
                userNames = formatString(userNames, maxWidth: Int(maxWidth - reactionLeftRightMargin))
                size = userNames.boundingRect(with: CGSize(width: maxWidth , height: 15), options: .usesLineFragmentOrigin, attributes: [.font : UIFont.systemFont(ofSize: 12)], context: nil)
            }
            reactionUserNames.append(userNames)
            let currentReactionWidth:CGFloat = ceil((reactionLeftRightMargin + size.width) + reactionPadding)
            
            if (currentWidth + currentReactionWidth) > maxWidth {
                if reactionIndex == (self.message.reactions.count - 1) {
                    if reactionIndex == 0 {
                        containerViewWidth = currentReactionWidth
                    } else {
                        containerViewWidth = max(containerViewWidth, currentReactionWidth)
                        userNameHeight += 30
                    }
                } else {
                    userNameHeight += 30
                    currentWidth = ceil(reactionLeftRightMargin + size.width)
                    containerViewWidth = max(containerViewWidth, currentWidth)
                }
            } else {
                if currentWidth > 0 {
                    currentWidth += currentReactionWidth
                } else {
                    currentWidth += ceil(reactionLeftRightMargin + size.width)
                }
                if containerViewWidth < maxWidth {
                    containerViewWidth = max(containerViewWidth, currentWidth)
                }
            }
        }
        
        reactionHeight = userNameHeight
        cellHeight += (userNameHeight + reactionMarginTop)
    }
    
    func getUserName(userID: String, groupID: String, completion: @escaping (String?) -> Void) {
        var userName:String = ""
        ZIMKit.queryUserInfoFromLocalCache(userID: userID, groupID: groupID) { userInfo in
            if userInfo!.name.count > 0 {
                userName = userInfo!.name
                completion(userName)
            } else {
                ZIMKit.queryUserInfo(by: userID) { userInfo, error in
                    userName = userInfo?.name ?? ""
                    completion(userName)
                }
            }
        }
    }
    
    func formatString(_ inputString: String, maxWidth: Int) -> String {
        let names = inputString.components(separatedBy: "，")
        var currentWidth = 0
        var result = ""
        var count = 0
        
        for name in names {
            let nameWidth = name.widthOfString(usingFont: UIFont.systemFont(ofSize: 12))
            if currentWidth + Int(nameWidth) + (result.isEmpty ? 0 : 15) > maxWidth {
                break
            }
            if !result.isEmpty {
                result += "，"
            }
            result += name
            currentWidth += Int(ceil(nameWidth)) + (result.isEmpty ? 0 : 15)
            count += 1
        }
        
        if names.count > count {
            result += "...+\(names.count - count)人"
        }
        
        return result
    }
    
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let size = (self as NSString).size(withAttributes: attributes)
        return size.width
    }
}
