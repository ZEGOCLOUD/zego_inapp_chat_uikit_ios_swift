//
//  RevokeMessageCell.swift
//  ZIMKit
//
//  Created by zego on 2024/8/5.
//

import UIKit

class RevokeMessageCell: MessageCell {
    
    override class var reuseId: String {
        String(describing: RevokeMessageCell.self)
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        updateMessageLabelConstraint()
    }
    
    private func updateMessageLabelConstraint() {
        contentView.addSubview(revokeLabel)
        NSLayoutConstraint.activate([
            revokeLabel.centerXAnchor.pin(equalTo: contentView.centerXAnchor),
            revokeLabel.topAnchor.pin(equalTo: contentView.topAnchor, constant: 4),
            revokeLabel.heightAnchor.pin(equalToConstant: 16.5)
        ])
    }
    
    override func updateContent() {
        super.updateContent()
        
        guard let messageVM = messageVM as? RevokeMessageViewModel else { return }
        
        updateMessageLabelConstraint()
        
        if let data = messageVM.message.revokeExtendedData.data(using:.utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
            
            revokeLabel.text = L10n("revoke_message", jsonObject["revokeUserName"] ?? "")
        } else {
            
        }
        
          revokeLabel.isHidden = messageVM.message.type == .revoke ? false : true
          timeLabel.isHidden = messageVM.message.type == .revoke ? true : false
          nameLabel.isHidden = messageVM.message.type == .revoke ? true : false
          avatarImageView.isHidden = messageVM.message.type == .revoke ? true : false
          containerView.isHidden = messageVM.message.type == .revoke ? true : false
          
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
