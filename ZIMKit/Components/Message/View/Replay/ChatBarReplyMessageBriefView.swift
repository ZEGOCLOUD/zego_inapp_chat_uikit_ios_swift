//
//  ChatBarReplyMessageBriefView.swift
//  ZIMKit
//
//  Created by zego on 2024/9/29.
//

import UIKit
protocol CancelReplyMessageDelegate: AnyObject {
    func cancelMessageReply()
}

class ChatBarReplyMessageBriefView: _View {
    
    lazy var replyBriefLabel: UILabel = {
        let label:UILabel = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = UIColor(hex: 0x646A73)
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    lazy var removeReplyButton: UIButton = {
        let button: UIButton = UIButton().withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "icon_reply_remove"), for: .normal)
        button.addTarget(self, action: #selector(removeReplyClick(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var lineView: UIView = {
        let view: UIView = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = UIColor(hex: 0xE6E6E6)
        return view
    }()
    
    
    weak var delegate: CancelReplyMessageDelegate?
    
    override func setUp() {
        super.setUp()
        
        backgroundColor = UIColor(hex: 0xF2F3F5, a: 0.9)
        layer.cornerRadius = 9.0
        layer.masksToBounds = true
        layer.cornerRadius = 4
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        
        addSubview(removeReplyButton)
        addSubview(lineView)
        addSubview(replyBriefLabel)
        
        NSLayoutConstraint.activate([
            removeReplyButton.centerYAnchor.pin(equalTo: self.centerYAnchor),
            removeReplyButton.leadingAnchor.pin(equalTo: self.leadingAnchor, constant: 10),
            removeReplyButton.heightAnchor.pin(equalToConstant: 14),
            removeReplyButton.widthAnchor.pin(equalToConstant: 14),
            
            lineView.centerYAnchor.pin(equalTo: self.removeReplyButton.centerYAnchor),
            lineView.leadingAnchor.pin(equalTo: self.removeReplyButton.trailingAnchor, constant: 10),
            lineView.heightAnchor.pin(equalToConstant: 14),
            lineView.widthAnchor.pin(equalToConstant: 1),
            
            replyBriefLabel.centerYAnchor.pin(equalTo: self.removeReplyButton.centerYAnchor),
            replyBriefLabel.leadingAnchor.pin(equalTo: self.lineView.trailingAnchor, constant: 10),
            replyBriefLabel.heightAnchor.pin(equalToConstant: 18),
            replyBriefLabel.trailingAnchor.pin(equalTo: self.trailingAnchor, constant: -10),
            
        ])
    }
    func updateReplyBriefContent(fromUserName:String,content:String) {
        replyBriefLabel.text = L10n("message_option_reply") + " " + fromUserName + ": " + content
    }
    
    @objc func removeReplyClick(_ button :UIButton) {
        delegate?.cancelMessageReply()
    }
}
