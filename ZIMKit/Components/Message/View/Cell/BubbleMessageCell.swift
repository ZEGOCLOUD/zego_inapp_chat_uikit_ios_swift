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
    var bubbleLeftConstraint: NSLayoutConstraint!
    var bubbleRightConstraint: NSLayoutConstraint!
    var bubbleTopConstraint: NSLayoutConstraint!
    var bubbleBottomConstraint: NSLayoutConstraint!
    
    override func setUpLayout() {
        super.setUpLayout()
        
        containerView.addSubview(bubbleView)
        
        bubbleLeftConstraint = bubbleView.leadingAnchor.pin(equalTo: containerView.leadingAnchor, constant: 0)
        bubbleRightConstraint = bubbleView.rightAnchor.pin(equalTo: containerView.rightAnchor, constant: 0)
        bubbleTopConstraint = bubbleView.topAnchor.pin(equalTo: containerView.topAnchor, constant: 0)
        bubbleBottomConstraint = bubbleView.bottomAnchor.pin(equalTo: containerView.bottomAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            bubbleLeftConstraint,
            bubbleRightConstraint,
            bubbleTopConstraint,
            bubbleBottomConstraint
            
        ])
        bubbleLeftConstraint.isActive = true
        bubbleRightConstraint.isActive = true
        bubbleTopConstraint.isActive = true
        bubbleBottomConstraint.isActive = true
    }
    
    override func updateContent() {
        super.updateContent()
        
        guard let messageVM = messageVM else { return }
        let message = messageVM.message
        
        let insets = UIEdgeInsets(top: 11, left: 12, bottom: 11, right: 12)
        if message.info.direction == .send {
            bubbleView.image = loadImageSafely(with: "send_bubble").resizableImage(withCapInsets: insets, resizingMode: .stretch)
        } else {
            bubbleView.image = loadImageSafely(with: "receve_bubble").resizableImage(withCapInsets: insets, resizingMode: .stretch)
        }
    }
}
