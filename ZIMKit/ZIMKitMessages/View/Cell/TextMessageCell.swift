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

    override func setUp() {
        super.setUp()
    }

    override func setUpLayout() {
        super.setUpLayout()
        updateMessageLabelConstraint()
    }

    private func updateMessageLabelConstraint() {
        let insets = message?.cellConfig.contentInsets ?? UIEdgeInsets()
        let directionInsets = NSDirectionalEdgeInsets(
            top: insets.top,
            leading: insets.left,
            bottom: insets.bottom,
            trailing: insets.right)
        messageLabel.removeFromSuperview()
        bubbleView.embed(messageLabel, insets: directionInsets)
    }

    override func updateContent() {
        super.updateContent()

        guard let message = message as? TextMessage else { return }
        updateMessageLabelConstraint()

        messageLabel.attributedText = message.attributedContent
        messageLabel.textColor = message.cellConfig.messageTextColor
        messageLabel.font = message.cellConfig.messageTextFont
    }
}
