//
//  BubbleMessageCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/18.
//

import Foundation

class BubbleMessageCell: MessageCell {

    override class var reuseId: String {
        String(describing: BubbleMessageCell.self)
    }

    lazy var bubbleView = UIImageView().withoutAutoresizingMaskConstraints

    override func setUp() {
        super.setUp()

        bubbleView.layer.cornerRadius = 8.0
        bubbleView.layer.masksToBounds = true
    }

    override func setUpLayout() {
        super.setUpLayout()
        containerView.embed(bubbleView)
    }

    override func updateContent() {
        super.updateContent()

        guard let message = message else { return }

        let insets = UIEdgeInsets(top: 11, left: 12, bottom: 11, right: 12)
        if message.direction == .send {
            bubbleView.image = loadImageSafely(with: "send_bubble").resizableImage(withCapInsets: insets, resizingMode: .stretch)
        } else {
            bubbleView.image = loadImageSafely(with: "receve_bubble").resizableImage(withCapInsets: insets, resizingMode: .stretch)
        }
    }
}
