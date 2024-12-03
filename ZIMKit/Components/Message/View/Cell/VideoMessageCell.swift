//
//  VideoMessageCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/15.
//

import Foundation

protocol VideoMessageCellDelegate: MessageCellDelegate {
    func videoMessageCell(_ cell: VideoMessageCell, didClickImageWith message: VideoMessageViewModel)
}

class VideoMessageCell: MessageCell {
    override class var reuseId: String {
        String(describing: VideoMessageCell.self)
    }
    
    lazy var videoMediaView: MediaVideoReplyView = {
        let view = MediaVideoReplyView().withoutAutoresizingMaskConstraints
        view.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    var videoTopConstraint: NSLayoutConstraint!
    var videoLeftConstraint: NSLayoutConstraint!
    var videoWidthConstraint: NSLayoutConstraint!
    var videoHeightConstraint: NSLayoutConstraint!
    
    override func setUp() {
        super.setUp()
        videoLeftConstraint = videoMediaView.leadingAnchor.pin(equalTo: containerView.leadingAnchor,constant: 0)
        videoTopConstraint = videoMediaView.topAnchor.pin(equalTo: containerView.topAnchor, constant: 0)
        videoWidthConstraint = videoMediaView.widthAnchor.pin(equalToConstant: 0)
        videoHeightConstraint = videoMediaView.heightAnchor.pin(equalToConstant: 0)
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        updateSubviewsConstraint()
    }
    
    func updateSubviewsConstraint() {
        containerView.addSubview(videoMediaView)
        guard let messageVM = messageVM as? VideoMessageViewModel else { return }
        videoWidthConstraint.constant = messageVM.contentMediaSize.width
        videoHeightConstraint.constant = messageVM.contentMediaSize.height
        NSLayoutConstraint.activate([
            videoHeightConstraint,
            videoWidthConstraint,
            videoLeftConstraint,
            videoTopConstraint
        ])
        
        videoLeftConstraint.isActive = true
        videoTopConstraint.isActive = true
        videoWidthConstraint.isActive = true
        videoHeightConstraint.isActive = true
    }
    
    override func updateContent() {
        super.updateContent()
        guard let messageVM = messageVM as? VideoMessageViewModel else { return }
        let message = messageVM.message
        updateSubviewsConstraint()
        
        videoMediaView.updateContent(messageVM: messageVM)
        
        if message.reactions.count > 0 {
            if message.info.direction == .send {
                containerView.backgroundColor = UIColor(hex: 0x3478FC)
            } else {
                containerView.backgroundColor = UIColor(hex: 0xFFFFFF)
            }
            containerView.layer.cornerRadius = 12
            
            videoTopConstraint.constant = 10
            videoLeftConstraint.constant = 12
            
        } else {
            videoTopConstraint.constant = 0
            videoLeftConstraint.constant = 0
        }
        
        videoWidthConstraint.constant = messageVM.contentMediaSize.width
        videoHeightConstraint.constant = messageVM.contentMediaSize.height
    }
}

extension VideoMessageCell {
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        guard let messageVM = messageVM as? VideoMessageViewModel else { return }
        let delegate = delegate as? VideoMessageCellDelegate
        delegate?.videoMessageCell(self, didClickImageWith: messageVM)
    }
}
