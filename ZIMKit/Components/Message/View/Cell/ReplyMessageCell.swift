//
//  ReplyMessageCell.swift
//  ZIMKit
//
//  Created by zego on 2024/9/5.
//

import UIKit
import ZIM



protocol ReplyMessageCellDelegate: MessageCellDelegate {
    func replyMessageCell(_ cell: ReplyMessageCell, didClickImageWith message: ReplyMessageViewModel)
    func replyMessageCell(_ cell: ReplyMessageCell, didClickVideoWith message: ReplyMessageViewModel)
    func replyMessageCell(_ cell: ReplyMessageCell, didClickFileWith message: ReplyMessageViewModel)
    func replyMessageCell(_ cell: ReplyMessageCell, didClickAudioWith message: ReplyMessageViewModel)
}

class ReplyMessageCell: MessageCell {
    
    override class var reuseId: String {
        String(describing: ReplyMessageCell.self)
    }
    
    lazy var lineView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.clipsToBounds = true
        view.backgroundColor = UIColor(hex: 0xFFFFFF)
        view.alpha = 0.7
        view.layer.cornerRadius = 2
        return view
    }()
    
    lazy var replyContentLB: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = UIColor(hex: 0xFFFFFF, a: 0.7)
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 1
//        label.alpha = 0.7
        return label
    }()
    
    lazy var contentLB: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .zim_textBlack1
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    lazy var imageMediaView: MediaImageReplyView = {
        let imageView = MediaImageReplyView().withoutAutoresizingMaskConstraints
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapImageAction(_:)))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    lazy var videoMediaView: MediaVideoReplyView = {
        let view = MediaVideoReplyView().withoutAutoresizingMaskConstraints
        view.isHidden = true
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapVideoAction(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var fileMediaView: MediaFileReplyView = {
        let view = MediaFileReplyView().withoutAutoresizingMaskConstraints
        view.isHidden = true
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFileAction(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var audioMediaView: MediaAudioReplyView = {
        let view = MediaAudioReplyView().withoutAutoresizingMaskConstraints
        view.isHidden = true
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAudioAction(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    var contentViewBottomConstraint: NSLayoutConstraint!
    var contentViewWidthConstraint: NSLayoutConstraint!
    
    lazy var replayContentView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        return view
    }()
    
    override func setUp() {
        super.setUp()
        containerView.layer.cornerRadius = 12.0
        contentViewBottomConstraint = replayContentView.bottomAnchor.pin(equalTo: containerView.bottomAnchor, constant: -10)
        contentViewWidthConstraint = replayContentView.widthAnchor.pin(equalToConstant: 0)
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        updateSubviewsConstraint()
    }
    
    private func updateSubviewsConstraint() {
        
        containerView.addSubview(lineView)
        containerView.addSubview(replyContentLB)
        containerView.addSubview(replayContentView)
        replayContentView.embed(contentLB)
        replayContentView.embed(imageMediaView)
        replayContentView.embed(videoMediaView)
        replayContentView.embed(fileMediaView)
        replayContentView.embed(audioMediaView)
        NSLayoutConstraint.activate([
            
            replyContentLB.leadingAnchor.pin(equalTo: lineView.trailingAnchor, constant: 5),
            replyContentLB.trailingAnchor.pin(equalTo: containerView.trailingAnchor, constant: -12),
            replyContentLB.topAnchor.pin(equalTo: containerView.topAnchor, constant: 12),
            replyContentLB.heightAnchor.pin(equalToConstant: 18),
            
            lineView.leadingAnchor.pin(equalTo: containerView.leadingAnchor, constant: 12),
            lineView.centerYAnchor.pin(equalTo: replyContentLB.centerYAnchor, constant: 0),
            lineView.heightAnchor.pin(equalToConstant: 14),
            lineView.widthAnchor.pin(equalToConstant: 2),
            
            replayContentView.leadingAnchor.pin(equalTo: containerView.leadingAnchor, constant: 12),
            replayContentView.topAnchor.pin(equalTo: replyContentLB.bottomAnchor, constant: 10),
            contentViewWidthConstraint,
            contentViewBottomConstraint,
            
        ])
        contentViewBottomConstraint.isActive = true
        contentViewWidthConstraint.isActive = true
    }
    
    
    override func updateContent() {
        super.updateContent()
        
        guard let messageVM = messageVM as? ReplyMessageViewModel else { return }
        updateSubviewsConstraint()
        
        fileMediaView.messageVM = messageVM
        
        if messageVM.message.info.direction == .send {
            containerView.backgroundColor = UIColor(hex: 0x3478FC)
            replyContentLB.textColor = UIColor(hex: 0xFFFFFF,a: 0.7)
            contentLB.textColor = .zim_textWhite
            lineView.backgroundColor = UIColor(hex: 0xFFFFFF)
        } else {
            containerView.backgroundColor = .zim_backgroundWhite
            replyContentLB.textColor = UIColor(hex: 0x646A73,a: 0.7)
            contentLB.textColor = .zim_textBlack1
            lineView.backgroundColor = UIColor(hex: 0xBBBFC3)
        }
        
        if messageVM.message.replyMessage is  ZIMTextMessageLiteInfo {
            let contentMsg:String = (messageVM.message.replyMessage as! ZIMTextMessageLiteInfo).message
            let attributedStr = NSMutableAttributedString(string: messageVM.replyTitle + contentMsg)
            if isAllEmoji(contentMsg) {
                
                let attributes: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 13),
                                                                  .foregroundColor : messageVM.message.info.direction == .send ? UIColor(hex: 0xFFFFFF,a: 0.7) : UIColor(hex: 0x646A73,a: 0.7)]
                
                let attributes1: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 13),
                                                                  .foregroundColor : UIColor(hex: 0xFFFFFF,a: 1)]
                
                attributedStr.setAttributes(attributes, range: NSRange(location: 0, length: messageVM.replyTitle.count))
                attributedStr.setAttributes(attributes1, range: NSRange(location: messageVM.replyTitle.count, length: contentMsg.count))
                replyContentLB.attributedText = attributedStr;

            } else {
                let attributedStr = NSMutableAttributedString(string: messageVM.replyTitle + contentMsg)

                let attributes: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 13),
                                                                  .foregroundColor : messageVM.message.info.direction == .send ? UIColor(hex: 0xFFFFFF,a: 0.7) : UIColor(hex: 0x646A73,a: 0.7)]
                attributedStr.setAttributes(attributes, range: NSRange(location: 0, length: (messageVM.replyTitle + contentMsg).count))
                replyContentLB.attributedText = attributedStr;
            }

        } else if messageVM.message.replyMessage is  ZIMAudioMessageLiteInfo {
            replyContentLB.text = messageVM.replyTitle + L10n("common_message_audio")
        } else if messageVM.message.replyMessage is  ZIMVideoMessageLiteInfo {
            replyContentLB.text = messageVM.replyTitle + L10n("common_message_video")
        } else if messageVM.message.replyMessage is  ZIMFileMessageLiteInfo {
            replyContentLB.text = messageVM.replyTitle + L10n("common_message_file")
        } else if messageVM.message.replyMessage is  ZIMImageMessageLiteInfo {
            replyContentLB.text = messageVM.replyTitle + L10n("common_message_photo")
        } else if messageVM.message.replyMessage is  ZIMCombineMessageLiteInfo {
            replyContentLB.text = messageVM.replyTitle + (messageVM.message.replyMessage as! ZIMCombineMessageLiteInfo).title
        }
        
        contentLB.text = messageVM.message.textContent.content
        
        if messageVM.message.type == .text {
            contentLB.isHidden = false
            imageMediaView.isHidden = true
            fileMediaView.isHidden = true
            videoMediaView.isHidden = true
            audioMediaView.isHidden = true
        } else if messageVM.message.type == .image {
            contentLB.isHidden = true
            videoMediaView.isHidden = true
            fileMediaView.isHidden = true
            audioMediaView.isHidden = true
            imageMediaView.isHidden = false
            let isResize = !messageVM.isGif && messageVM.message.fileSize > 5 * 1024 * 1024
            imageMediaView.updateContent(messageVM: messageVM,isResize: isResize)
        } else if messageVM.message.type == .video {
            contentLB.isHidden = true
            imageMediaView.isHidden = true
            fileMediaView.isHidden = true
            audioMediaView.isHidden = true
            videoMediaView.isHidden = false
            videoMediaView.updateContent(messageVM: messageVM)
        } else if messageVM.message.type == .file {
            contentLB.isHidden = true
            imageMediaView.isHidden = true
            videoMediaView.isHidden = true
            audioMediaView.isHidden = true
            fileMediaView.isHidden = false
            
            fileMediaView.messageVM = messageVM
            fileMediaView.updateContent(messageVM: messageVM)
        } else if messageVM.message.type == .audio {
            contentLB.isHidden = true
            imageMediaView.isHidden = true
            videoMediaView.isHidden = true
            fileMediaView.isHidden = true
            audioMediaView.isHidden = false
            
            audioMediaView.messageVM = messageVM
            audioMediaView.updateContent(messageVM: messageVM)
        }
        
        contentViewBottomConstraint?.constant = -(messageVM.reactionHeight > 0 ? (messageVM.reactionHeight + 20 ) : 10)
        contentViewWidthConstraint?.constant = messageVM.message.type == .text ? (messageVM.contentSize.width - 20) : messageVM.contentMediaSize.width
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func isAllEmoji(_ str: String) -> Bool {
        for char in str {
                let scalar = char.unicodeScalars.first!
                let scalarValue = scalar.value
                let isEmojiRange1 = (0x1F600...0x1F64F).contains(scalarValue)
                let isEmojiRange2 = (0x1F300...0x1F5FF).contains(scalarValue)
                let isEmojiRange3 = (0x2600...0x26FF).contains(scalarValue)
                let isEmojiRange4 = (0x2700...0x27BF).contains(scalarValue)
                if !isEmojiRange1 && !isEmojiRange2 && !isEmojiRange3 && !isEmojiRange4 {
                    return false
                }
            }
            return true
    }
    
}

extension ReplyMessageCell {
    @objc func tapImageAction(_ tap: UITapGestureRecognizer) {
        guard let messageVM = messageVM as? ReplyMessageViewModel else { return }
        let delegate = delegate as? ReplyMessageCellDelegate
        delegate?.replyMessageCell(self, didClickImageWith: messageVM)
    }
    
    @objc func tapVideoAction(_ tap: UITapGestureRecognizer) {
        guard let messageVM = messageVM as? ReplyMessageViewModel else { return }
        let delegate = delegate as? ReplyMessageCellDelegate
        delegate?.replyMessageCell(self, didClickVideoWith: messageVM)
    }
    
    @objc func tapFileAction(_ tap: UITapGestureRecognizer) {
        guard let messageVM = messageVM as? ReplyMessageViewModel else { return }
        let delegate = delegate as? ReplyMessageCellDelegate
        delegate?.replyMessageCell(self, didClickFileWith: messageVM)
    }
    
    @objc func tapAudioAction(_ tap: UITapGestureRecognizer) {
        if let messageVM = messageVM as? ReplyMessageViewModel {
            let delegate = delegate as? ReplyMessageCellDelegate
            delegate?.replyMessageCell(self, didClickAudioWith: messageVM)
        }
    }
}
