//
//  TipsMessageCell.swift
//  ZIMKit
//
//  Created by zego on 2024/8/23.
//

import UIKit
import ZIM
class TipsMessageCell: MessageCell {
    
    
    override class var reuseId: String {
        String(describing: TipsMessageCell.self)
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        updateTipsLabelConstraint()
    }
    
    private func updateTipsLabelConstraint() {
        contentView.addSubview(tipsLabel)
        NSLayoutConstraint.activate([
            tipsLabel.centerXAnchor.pin(equalTo: contentView.centerXAnchor),
            tipsLabel.centerYAnchor.pin(equalTo: contentView.centerYAnchor),
            tipsLabel.leadingAnchor.pin(equalTo: contentView.leadingAnchor, constant: 46),
            tipsLabel.trailingAnchor.pin(equalTo: contentView.trailingAnchor, constant: -46),
        ])
    }
    
    override func updateContent() {
        super.updateContent()
        
        guard let messageVM = messageVM as? TipsMessageViewModel else { return }
        
        updateTipsLabelConstraint()
        
        tipsLabel.attributedText = messageVM.attributedContent
        
        
        if messageVM.message.type == .tips {
            tipsLabel.isHidden = messageVM.message.type == .tips ? false : true
            revokeLabel.isHidden = messageVM.message.type == .tips ? true : false
            timeLabel.isHidden = messageVM.message.type == .tips ? true : false
            nameLabel.isHidden = messageVM.message.type == .tips ? true : false
            avatarImageView.isHidden = messageVM.message.type == .tips ? true : false
            containerView.isHidden = messageVM.message.type == .tips ? true : false
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
