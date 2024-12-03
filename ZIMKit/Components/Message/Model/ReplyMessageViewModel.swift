//
//  ReplyMessageViewModel.swift
//  ZIMKit
//
//  Created by zego on 2024/9/5.
//

import UIKit
import ZIM

let MessageCell_Reply_Max_Width = UIScreen.main.bounds.width - 150.0


class ReplyMessageViewModel: MediaMessageViewModel {
    override init(with msg: ZIMKitMessage) {
        super.init(with: msg)
        
        cellConfig.contentInsets = UIEdgeInsets(top: 11, left: 0, bottom: 11, right: 0)
        
        if msg.type == .file {
            let fileLocalPath = msg.fileLocalPath
            if fileLocalPath.count > 0 &&
                !FileManager.default.fileExists(atPath: fileLocalPath) {
                
                let home = NSHomeDirectory()
                msg.fileLocalPath = home + fileLocalPath[home.endIndex..<fileLocalPath.endIndex]
            }
        }
    }
    
    var isGif: Bool {
        let url = URL(fileURLWithPath: message.fileName)
        return url.pathExtension.lowercased() == "gif"
    }
    
    var replyTitle:String = ""
    override var contentSize: CGSize {
        let originMsgHeight:CGFloat = 22.0
        let centerHeight:CGFloat = 8.0
        
        var contentMessageHeight:CGFloat = 0.0
        var contentMessageWidth:CGFloat = 0.0
        
        
        var originMessageWidth:CGFloat = 0.0
        
        var contentViewWidth:CGFloat = 0.0
        
        let sendUserID:String = message.zim?.repliedInfo?.senderUserID ?? ""
        let semaphore = DispatchSemaphore(value: 1)

        var sendUserName = ""
        ZIMKit.queryUserInfo(by: sendUserID) { userInfo, error in
            semaphore.signal()
            sendUserName = userInfo?.name ?? ""
        }
        semaphore.wait()

        replyTitle = L10n("message_option_reply") + sendUserName + "："
        
        switch message.type {
        case .text:
            let textModel:TextMessageViewModel = TextMessageViewModel(with: message)
            contentMessageHeight = textModel.contentSize.height
            contentMessageWidth = textModel.contentSize.width
            
        case .image:
            let imageModel:ImageMessageViewModel = ImageMessageViewModel(with: message)
            contentMessageHeight = imageModel.contentSize.height
            contentMessageWidth = imageModel.contentSize.width
            contentMediaSize = CGSizeMake(contentMessageWidth, contentMessageHeight)
        case .audio:
            let audioModel:AudioMessageViewModel = AudioMessageViewModel(with: message)
            contentMessageHeight = audioModel.contentSize.height
            contentMessageWidth = audioModel.contentSize.width
            contentMediaSize = CGSizeMake(contentMessageWidth, contentMessageHeight)
        case .video:
            let videoModel:VideoMessageViewModel = VideoMessageViewModel(with: message)
            contentMessageHeight = videoModel.contentSize.height
            contentMessageWidth = videoModel.contentSize.width
            contentMediaSize = CGSizeMake(contentMessageWidth, contentMessageHeight)
        case .file:
            let fileModel:FileMessageViewModel = FileMessageViewModel(with: message)
            contentMessageHeight = fileModel.contentSize.height
            contentMessageWidth = fileModel.contentSize.width
            contentMediaSize = CGSizeMake(contentMessageWidth, contentMessageHeight)
        default:
            contentMessageHeight = 0.0
        }
        
        if message.replyMessage != nil {
             let marginBoth:CGFloat = 30
            let font = UIFont.systemFont(ofSize: 13)
            var replyOrigin = replyTitle
            if message.replyMessage is  ZIMTextMessageLiteInfo {
                replyOrigin = replyOrigin + (message.replyMessage as! ZIMTextMessageLiteInfo).message
            } else if message.replyMessage is  ZIMCombineMessageLiteInfo {
                replyOrigin = replyOrigin + (message.replyMessage as! ZIMCombineMessageLiteInfo).title
            }else if message.replyMessage is  ZIMAudioMessageLiteInfo {
                replyOrigin = replyOrigin + L10n("common_message_audio")
            } else if message.replyMessage is  ZIMVideoMessageLiteInfo {
                replyOrigin = replyOrigin + L10n("common_message_video")
            } else if message.replyMessage is  ZIMFileMessageLiteInfo {
                replyOrigin = replyOrigin + L10n("common_message_file")
            } else if message.replyMessage is  ZIMImageMessageLiteInfo {
                replyOrigin = replyOrigin + L10n("common_message_photo")
            } else {
                replyOrigin = replyOrigin + message.getShortString()
            }
            let size = replyOrigin.boundingRect(with: CGSize(width: (MessageCell_Reply_Max_Width - 24), height: 18), options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
            originMessageWidth = size.width + marginBoth
            
        }
        
        contentViewWidth = max(originMessageWidth, contentMessageWidth)
        
        if contentViewWidth > MessageCell_Reply_Max_Width {
            contentViewWidth = MessageCell_Reply_Max_Width
        }
        
        return CGSize(width: contentViewWidth + 20, height:  originMsgHeight + centerHeight + contentMessageHeight)
    }
    
    
}
