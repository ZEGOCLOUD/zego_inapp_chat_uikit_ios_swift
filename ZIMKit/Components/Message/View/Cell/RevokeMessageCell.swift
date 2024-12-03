//
//  RevokeMessageCell.swift
//  ZIMKit
//
//  Created by zego on 2024/8/5.
//

import UIKit
import ZIM
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
            revokeLabel.centerYAnchor.pin(equalTo: contentView.centerYAnchor),
            revokeLabel.rightAnchor.pin(equalTo: contentView.rightAnchor, constant: -4),
            revokeLabel.leadingAnchor.pin(equalTo: contentView.leadingAnchor, constant: 4),
            revokeLabel.heightAnchor.pin(equalToConstant: 15)
        ])
    }
    
    override func updateContent() {
        super.updateContent()
        
        guard let messageVM = messageVM as? RevokeMessageViewModel else { return }
        guard let messageZIM:ZIMRevokeMessage = messageVM.message.zim as? ZIMRevokeMessage else { return }
        updateMessageLabelConstraint()
        
        if messageVM.message.info.senderUserID == ZIMKit.localUser?.id {
            revokeLabel.text = L10n("revoke_message", L10n("you") )
        } else {
            ZIMKit.queryUserInfo(by: messageVM.message.info.senderUserID) {[weak self] userInfo, error in
                self?.revokeLabel.text = L10n("revoke_message", userInfo?.name ?? "")
                self?.setRevokeAttributedText(originalString: (self?.revokeLabel.text)!, colorStr: userInfo?.name ?? "")
            }
        }
        
        if messageVM.message.type == .revoke {
            revokeLabel.isHidden = messageVM.message.type == .revoke ? false : true
            timeLabel.isHidden = messageVM.message.type == .revoke ? true : false
            nameLabel.isHidden = messageVM.message.type == .revoke ? true : false
            avatarImageView.isHidden = messageVM.message.type == .revoke ? true : false
            containerView.isHidden = messageVM.message.type == .revoke ? true : false
            nameLabel.isHidden = messageVM.message.type == .revoke ? true : false
        }
    }
    
    func setRevokeAttributedText(originalString: String, colorStr: String) {
        let rangeToColor = (originalString as NSString).range(of: colorStr)
        
        let attributedString = NSMutableAttributedString(string: originalString)
        attributedString.addAttribute(.foregroundColor, value: UIColor(hex: 0x3478FC), range: rangeToColor)
        revokeLabel.attributedText = attributedString
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
