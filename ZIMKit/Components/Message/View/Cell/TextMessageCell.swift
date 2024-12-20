//
//  TextMessageCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/18.
//

import Foundation

class TextMessageCell: BubbleMessageCell {
    override class var reuseId: String {
        String(describing: TextMessageCell.self)
    }
    
    lazy var messageLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var loadingView: DotAnimationView = {
        let animationView = DotAnimationView().withoutAutoresizingMaskConstraints
        animationView.isHidden = true
        return animationView
    }()
    
    override func setUp() {
        super.setUp()
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        updateMessageLabelConstraint()
    }
    
    private func updateMessageLabelConstraint() {

        bubbleView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.pin(equalTo: bubbleView.leadingAnchor,constant: 12),
            messageLabel.topAnchor.pin(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.trailingAnchor.pin(equalTo: bubbleView.trailingAnchor,constant: -12),
        ])
        
        bubbleView.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.centerYAnchor.pin(equalTo: bubbleView.centerYAnchor, constant: 5),
            loadingView.centerXAnchor.pin(equalTo: bubbleView.centerXAnchor, constant: 9),
            loadingView.heightAnchor.pin(equalToConstant: 10),
            loadingView.widthAnchor.pin(equalToConstant: 40)
        ])
    }
    
    override func updateContent() {
        super.updateContent()
        
        guard let messageVM = messageVM as? TextMessageViewModel else { return }
        updateMessageLabelConstraint()
        
        messageLabel.attributedText = messageVM.attributedContent
        messageLabel.textColor = messageVM.cellConfig.messageTextColor
        messageLabel.font = messageVM.cellConfig.messageTextFont
        
        if ZIMKit().imKitConfig.advancedConfig != nil && ((ZIMKit().imKitConfig.advancedConfig?.keys.contains(ZIMKitAdvancedKey.showLoadingWhenSend)) != nil && messageVM.message.textContent.content == "[...]") {
            messageLabel.isHidden = true
            loadingView.isHidden = false
            loadingView.startAnimation()
        } else {
            messageLabel.isHidden = false
            loadingView.isHidden = true
            loadingView.stopAnimation()
        }
    }
}
