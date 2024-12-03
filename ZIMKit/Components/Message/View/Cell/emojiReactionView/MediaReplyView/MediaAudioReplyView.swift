//
//  MediaAudioReplyView.swift
//  ZIMKit
//
//  Created by zego on 2024/10/14.
//

import UIKit

class MediaAudioReplyView: UIView {
    lazy var bubbleView: UIImageView = {
        let view = UIImageView().withoutAutoresizingMaskConstraints
        view.clipsToBounds = true
        return view
    }()
    
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
    
    var messageVM: ReplyMessageViewModel? {
        didSet {
            guard let messageVM = messageVM else { return }
            if messageVM.message.type == .audio {
                messageVM.$isDownloading.bindOnce { [weak self] _ in
                    self?.updateBubbleAnimation(with: messageVM)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        addSubviews()
        updateSubviewsConstraint()
    }
    
    private func addSubviews() {
        embed(bubbleView)
        
        bubbleView.addSubview(iconImageView)
        bubbleView.addSubview(durationLabel)
        
        iconImageView.pin(to: 22)
        iconImageView.pin(anchors: [.centerY], to: bubbleView)
        
        durationLabel.pin(anchors: [.centerY], to: bubbleView)
        durationLabel.heightAnchor.pin(equalToConstant: 21).isActive = true
    }
    
    private func updateSubviewsConstraint() {
        var imageViewConstraint: NSLayoutConstraint!
        var labelConstraint: NSLayoutConstraint!
        
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
    
    func updateContent(messageVM:ReplyMessageViewModel) {
        
        guard let messageVM = messageVM as? ReplyMessageViewModel else { return }
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
        
        let insets = UIEdgeInsets(top: 11, left: 12, bottom: 11, right: 12)
        if message.info.direction == .send {
            if let image = generateImageWithColor(colorHex: "#1A63F1") {
                bubbleView.image = image.resizableImage(withCapInsets: insets, resizingMode: .stretch)
            }
        } else {
            if let image = generateImageWithColor(colorHex: "#EFF0F2") {
                bubbleView.image = image.resizableImage(withCapInsets: insets, resizingMode: .stretch)
            }
        }
        bubbleView.layer.cornerRadius = 12
    }
    
    private func updateBubbleAnimation(with messageVM: ReplyMessageViewModel) {
        setupBubbleAnimations(with: messageVM)
        if !FileManager.default.fileExists(atPath: messageVM.message.fileLocalPath) {
            bubbleView.subviews.forEach({ $0.isHidden = true })
            bubbleView.startAnimating()
        } else {
            bubbleView.subviews.forEach({ $0.isHidden = false })
            bubbleView.stopAnimating()
        }
    }
    
    private func setupBubbleAnimations(with messageVM: ReplyMessageViewModel) {
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
    
    func startAudioAnimation() {
        iconImageView.startAnimating()
    }
    
    func stopAudioAnimation() {
        iconImageView.stopAnimating()
    }
    
}

