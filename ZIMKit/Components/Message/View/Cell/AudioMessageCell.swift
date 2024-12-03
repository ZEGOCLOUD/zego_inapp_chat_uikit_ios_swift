//
//  AudioMessageCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/6.
//

import Foundation

protocol AudioMessageCellDelegate: MessageCellDelegate {
    func audioMessageCell(_ cell: AudioMessageCell, didClickWith message: AudioMessageViewModel)
}

class AudioMessageCell: BubbleMessageCell {
    override class var reuseId: String {
        String(describing: AudioMessageCell.self)
    }
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.animationDuration = 1.0
        return imageView
    }()
    
    lazy var durationLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    var imageViewConstraint: NSLayoutConstraint!
    var labelConstraint: NSLayoutConstraint!
    
    override var messageVM: MessageViewModel? {
        didSet {
            guard let messageVM = messageVM as? AudioMessageViewModel else { return }
            if messageVM.message.type != .audio { return }
            messageVM.$isDownloading.bindOnce { [weak self] _ in
                // when callback, self.message maybe is another object.
                if self?.messageVM !== messageVM { return }
                self?.updateBubbleAnimation(with: messageVM)
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        containerView.addGestureRecognizer(tap)
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        
        bubbleView.addSubview(iconImageView)
        bubbleView.addSubview(durationLabel)
        
        iconImageView.pin(to: 22)
        iconImageView.pin(anchors: [.centerY], to: bubbleView)
        
        durationLabel.pin(anchors: [.centerY], to: bubbleView)
        durationLabel.heightAnchor.pin(equalToConstant: 21).isActive = true
        
        updateAllConstraints()
    }
    
    private func updateAllConstraints() {
        if imageViewConstraint != nil {
            imageViewConstraint.isActive = false
        }
        if labelConstraint != nil {
            labelConstraint.isActive = false
        }
        
        if messageVM?.message.info.direction == .send {
            imageViewConstraint = iconImageView.trailingAnchor.pin(
                equalTo: bubbleView.trailingAnchor,
                constant: -12)
            labelConstraint = durationLabel.trailingAnchor.pin(
                equalTo: iconImageView.leadingAnchor,
                constant: -4)
        } else {
            imageViewConstraint = iconImageView.leadingAnchor.pin(
                equalTo: bubbleView.leadingAnchor,
                constant: 12)
            labelConstraint = durationLabel.leadingAnchor.pin(
                equalTo: iconImageView.trailingAnchor,
                constant: 4)
        }
        
        NSLayoutConstraint.activate([
            imageViewConstraint,
            labelConstraint
        ])
    }
    
    override func updateContent() {
        super.updateContent()
        
        guard let messageVM = messageVM as? AudioMessageViewModel else { return }
        let message = messageVM.message
        
        if message.info.direction == .send {
            iconImageView.image = loadImageSafely(with: "voice_send_icon_3")
            iconImageView.animationImages = [
                loadImageSafely(with: "voice_send_icon_1"),
                loadImageSafely(with: "voice_send_icon_2"),
                loadImageSafely(with: "voice_send_icon_3")
            ]
        } else {
            iconImageView.image = loadImageSafely(with: "voice_receive_icon_3")
            iconImageView.animationImages = [
                loadImageSafely(with: "voice_receive_icon_1"),
                loadImageSafely(with: "voice_receive_icon_2"),
                loadImageSafely(with: "voice_receive_icon_3")
            ]
        }
        durationLabel.textColor = messageVM.cellConfig.messageTextColor
        durationLabel.text = String(format: "%d\"", message.audioContent.duration)
        
        if messageVM.isPlayingAudio {
            startAudioAnimation()
        } else {
            stopAudioAnimation()
        }
        
        updateAllConstraints()
        
        if message.reactions.count > 0 {
            let insets = UIEdgeInsets(top: 11, left: 12, bottom: 11, right: 12)
            
            if message.info.direction == .send {
                containerView.backgroundColor = UIColor(hex: 0x3478FC)
                if let image = generateImageWithColor(colorHex: "#1A63F1") {
                    bubbleView.image = image.resizableImage(withCapInsets: insets, resizingMode: .stretch)
                }
            } else {
                containerView.backgroundColor = UIColor(hex: 0xFFFFFF)
                if let image = generateImageWithColor(colorHex: "#EFF0F2") {
                    bubbleView.image = image.resizableImage(withCapInsets: insets, resizingMode: .stretch)
                }
            }
            containerView.layer.cornerRadius = 12
            
            bubbleLeftConstraint.constant = 10
            bubbleTopConstraint.constant = 12
            bubbleRightConstraint.constant = -(containerWidthConstraint.constant - (10 + messageVM.contentMediaSize.width))
            bubbleBottomConstraint.constant = -(messageVM.reactionHeight + 20)
        } else {
            bubbleLeftConstraint.constant = 0
            bubbleTopConstraint.constant = 0
            bubbleRightConstraint.constant = 0
            bubbleBottomConstraint.constant = 0
        }
    }
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        if let messageVM = messageVM as? AudioMessageViewModel {
            let delegate = delegate as? AudioMessageCellDelegate
            delegate?.audioMessageCell(self, didClickWith: messageVM)
        }
    }
    
    private func updateBubbleAnimation(with messageVM: AudioMessageViewModel) {
        setupBubbleAnimations(with: messageVM)
        if !FileManager.default.fileExists(atPath: messageVM.message.fileLocalPath) {
            bubbleView.subviews.forEach({ $0.isHidden = true })
            bubbleView.startAnimating()
        } else {
            bubbleView.subviews.forEach({ $0.isHidden = false })
            bubbleView.stopAnimating()
        }
    }
    
    private func setupBubbleAnimations(with messageVM: AudioMessageViewModel) {
        let message = messageVM.message
        var animationImages: [UIImage] = []
        
        if message.info.direction == .receive {
            if let image = UIImage.image(with: .zim_backgroundWhite) {
                animationImages.append(image)
            }
            if let image = UIImage.image(with: .zim_backgroundWhite.withAlphaComponent(0.6)) {
                animationImages.append(image)
            }
        } else {
            if let image = UIImage.image(with: .zim_backgroundBlue2) {
                animationImages.append(image)
            }
            if let image = UIImage.image(with: .zim_backgroundBlue2.withAlphaComponent(0.6)) {
                animationImages.append(image)
            }
        }
        bubbleView.animationImages = animationImages
        bubbleView.animationDuration = 1.0
    }
}

extension AudioMessageCell {
    func startAudioAnimation() {
        iconImageView.startAnimating()
    }
    
    func stopAudioAnimation() {
        iconImageView.stopAnimating()
    }
}
