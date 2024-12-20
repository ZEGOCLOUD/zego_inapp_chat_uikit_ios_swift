//
//  ImageMessageCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/18.
//

import Foundation
import Kingfisher

protocol ImageMessageCellDelegate: MessageCellDelegate {
    func imageMessageCell(_ cell: ImageMessageCell, didClickImageWith message: ImageMessageViewModel)
}

class ImageMessageCell: MessageCell {
    override class var reuseId: String {
        String(describing: ImageMessageCell.self)
    }
    
    lazy var imageMediaView: MediaImageReplyView = {
        let imageView = MediaImageReplyView().withoutAutoresizingMaskConstraints
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        imageView.addGestureRecognizer(tap)
        
        return imageView
    }()
    
    var imageTopConstraint: NSLayoutConstraint!
    var imageLeftConstraint: NSLayoutConstraint!
    var imageWidthConstraint: NSLayoutConstraint!
    var imageHeightConstraint: NSLayoutConstraint!
    override func setUp() {
        super.setUp()
        imageLeftConstraint = imageMediaView.leadingAnchor.pin(equalTo: containerView.leadingAnchor,constant: 0)
        imageTopConstraint = imageMediaView.topAnchor.pin(equalTo: containerView.topAnchor, constant: 0)
        imageWidthConstraint = imageMediaView.widthAnchor.pin(equalToConstant: 0)
        imageHeightConstraint = imageMediaView.heightAnchor.pin(equalToConstant: 0)
        
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        updateImageConstraint()
    }
    
    private func updateImageConstraint() {
        //        let insets = messageVM?.cellConfig.contentInsets ?? UIEdgeInsets()
        guard messageVM is ImageMessageViewModel else { return }
        
        containerView.addSubview(imageMediaView)
        
        NSLayoutConstraint.activate([
            imageLeftConstraint,
            imageTopConstraint,
            imageWidthConstraint,
            imageHeightConstraint
        ])
        
        containerView.embed(progressView)
        
        imageLeftConstraint.isActive = true
        imageTopConstraint.isActive = true
        imageWidthConstraint.isActive = true
        imageHeightConstraint.isActive = true
    }
    
    override func updateContent() {
        super.updateContent()
        
        guard let messageVM = messageVM as? ImageMessageViewModel else { return }
        let message = messageVM.message
        
        updateImageConstraint()
        
        let isResize = !messageVM.isGif && message.fileSize > 5 * 1024 * 1024
        imageMediaView.updateContent(messageVM: messageVM,isResize: isResize)
        
        if message.reactions.count > 0 {
            if message.info.direction == .send {
                containerView.backgroundColor = UIColor(hex: 0x3478FC)
            } else {
                containerView.backgroundColor = UIColor(hex: 0xFFFFFF)
            }
            containerView.layer.cornerRadius = 12
            
            imageTopConstraint.constant = 10
            imageLeftConstraint.constant = 12
            
        } else {
            imageTopConstraint.constant = 0
            imageLeftConstraint.constant = 0
        }
        imageWidthConstraint.constant = messageVM.contentMediaSize.width
        imageHeightConstraint.constant = messageVM.contentMediaSize.height
    }
    
}

extension ImageMessageCell {
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        if let messageVM = messageVM as? ImageMessageViewModel {
            let delegate = delegate as? ImageMessageCellDelegate
            delegate?.imageMessageCell(self, didClickImageWith: messageVM)
        }
    }
}
