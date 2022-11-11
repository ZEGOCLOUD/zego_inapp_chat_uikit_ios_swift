//
//  SystemMessageCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/18.
//

import Foundation

class SystemMessageCell: MessageCell {

    override class var reuseId: String {
        String(describing: SystemMessageCell.self)
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
            messageLabel.heightAnchor.pin(equalToConstant: message?.contentSize.height ?? 18.0)
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
        if message?.isShowTime == true {
            messageLabelTopConstraint = messageLabel.topAnchor.pin(
                equalTo: timeLabel.bottomAnchor,
                constant: 12)
        }
        messageLabelTopConstraint.isActive = true

        messageLabelHeightConstraint.constant = message?.contentSize.height ?? 18.0
    }

    override func updateContent() {

        updateMessageLabelConstraint()

        guard let message = message as? SystemMessage else { return }

        messageLabel.attributedText = message.attributedContent
        timeLabel.text = timestampToMessageDateStr(message.timestamp)
    }
}
