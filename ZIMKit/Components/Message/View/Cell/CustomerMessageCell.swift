//
//  CustomerMessageCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/18.
//

import Foundation
import ZIM
class CustomerMessageCell: MessageCell {
    
    override class var reuseId: String {
        String(describing: CustomerMessageCell.self)
    }
    
    lazy var messageLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .zim_textGray2
        label.numberOfLines = 0
        return label
    }()
    
    private var messageLabelTopConstraint: NSLayoutConstraint!
    private var messageLabelHeightConstraint: NSLayoutConstraint!
    
    override func setUp() {
        super.setUp()
    }
    
    override func setUpLayout() {
        contentView.addSubview(timeLabel)
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.pin(equalTo: contentView.centerXAnchor),
            timeLabel.topAnchor.pin(equalTo: contentView.topAnchor, constant: 4),
            timeLabel.heightAnchor.pin(equalToConstant: 16.5)
        ])
        
        contentView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.pin(equalTo: contentView.leadingAnchor, constant: 30),
            messageLabel.trailingAnchor.pin(equalTo: contentView.trailingAnchor, constant: -30),
            messageLabel.heightAnchor.pin(equalToConstant: messageVM?.contentSize.height ?? 18.0)
        ])
        messageLabelHeightConstraint = messageLabel.heightAnchor.pin(equalToConstant: 18.0)
        messageLabelHeightConstraint.isActive = true
        updateMessageLabelConstraint()
    }
    
    private func updateMessageLabelConstraint() {
        if messageLabelTopConstraint != nil {
            messageLabelTopConstraint.isActive = false
        }
        messageLabelTopConstraint = messageLabel.topAnchor.pin(
            equalTo: contentView.topAnchor,
            constant: 12)
        if messageVM?.isShowTime == true {
            messageLabelTopConstraint = messageLabel.topAnchor.pin(
                equalTo: timeLabel.bottomAnchor,
                constant: 12)
        }
        messageLabelTopConstraint.isActive = true
        messageLabelHeightConstraint.constant = messageVM?.contentSize.height ?? 18.0
        timeLabel.isHidden = true
    }
    
    override func updateContent() {
        
        updateMessageLabelConstraint()
        guard let messageVM = messageVM as? CustomerMessageViewModel else { return }
        
        messageLabel.attributedText = messageVM.attributedContent
        timeLabel.text = timestampToMessageDateStr(messageVM.message.info.timestamp)
        
        if messageVM.message.zim is ZIMCustomMessage  {
            if (messageVM.message.zim as! ZIMCustomMessage).subType == systemMessageSubType {
                timeLabel.isHidden = false
            } else {
                timeLabel.isHidden = true
            }
        } else {
            timeLabel.isHidden = true
        }
    }
}
