//
//  AudioMessageCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/6.
//

import Foundation

protocol AudioMessageCellDelegate: MessageCellDelegate {
    func audioMessageCell(_ cell: AudioMessageCell, didClickWith message: AudioMessage)
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

    override var message: Message? {
        didSet {
            guard let message = message as? AudioMessage else { return }
            message.$fileLocalPath.bindOnce { [weak self] _ in
                // when callback, self.message maybe is another object.
                if self?.message !== message { return }
                self?.updateBubbleAnimation(with: message)
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

        if message?.direction == .send {
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

        guard let message = message as? AudioMessage else { return }

        if message.direction == .send {
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
        durationLabel.textColor = message.cellConfig.messageTextColor
        durationLabel.text = String(format: "%d\"", message.duration)

        if message.isPlayingAudio {
            startAudioAnimation()
        } else {
            stopAudioAnimation()
        }

        updateAllConstraints()
    }

    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        if let message = message as? AudioMessage {
            let delegate = delegate as? AudioMessageCellDelegate
            delegate?.audioMessageCell(self, didClickWith: message)
        }
    }

    private func updateBubbleAnimation(with message: AudioMessage) {
        setupBubbleAnimations(with: message)
        if !FileManager.default.fileExists(atPath: message.fileLocalPath) {
            bubbleView.subviews.forEach({ $0.isHidden = true })
            bubbleView.startAnimating()
        } else {
            bubbleView.subviews.forEach({ $0.isHidden = false })
            bubbleView.stopAnimating()
        }
    }

    private func setupBubbleAnimations(with message: AudioMessage) {

        var animationImages: [UIImage] = []

        if message.direction == .receive {
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
