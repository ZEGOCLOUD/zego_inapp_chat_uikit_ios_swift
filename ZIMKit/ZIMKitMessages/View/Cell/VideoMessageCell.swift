//
//  VideoMessageCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/15.
//

import Foundation

protocol VideoMessageCellDelegate: MessageCellDelegate {
    func videoMessageCell(_ cell: VideoMessageCell, didClickImageWith message: VideoMessage)
}

class VideoMessageCell: MessageCell {
    override class var reuseId: String {
        String(describing: VideoMessageCell.self)
    }

    lazy var videoImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    lazy var playImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.image = loadImageSafely(with: "message_video_play")
        imageView.layer.cornerRadius = 22.0
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    lazy var durationLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .zim_textWhite
        label.textAlignment = .right
        return label
    }()

    override func setUp() {
        super.setUp()

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        videoImageView.addGestureRecognizer(tap)
        videoImageView.isUserInteractionEnabled = true
    }

    override func setUpLayout() {
        super.setUpLayout()

        containerView.embed(videoImageView)

        containerView.addSubview(playImageView)
        playImageView.pin(anchors: [.centerX, .centerY], to: containerView)
        playImageView.pin(to: 44.0)

        containerView.addSubview(durationLabel)
        NSLayoutConstraint.activate([
            durationLabel.trailingAnchor.pin(equalTo: containerView.trailingAnchor, constant: -8),
            durationLabel.bottomAnchor.pin(equalTo: containerView.bottomAnchor, constant: -5),
            durationLabel.heightAnchor.pin(equalToConstant: 14)
        ])
    }

    override func updateContent() {
        super.updateContent()

        guard let message = message as? VideoMessage else { return }

        let placeHolder = "chat_image_fail_bg"
        let url = message.firstFrameDownloadUrl.count > 0
            ? message.firstFrameDownloadUrl
            : message.firstFrameLocalPath
        videoImageView.loadImage(with: url, placeholder: placeHolder)

        let min = message.duration / 60
        let seconds = message.duration % 60
        durationLabel.text = String(format: "%d:%02d", min, seconds)
    }
}

extension VideoMessageCell {
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        guard let message = message as? VideoMessage else { return }
        let delegate = delegate as? VideoMessageCellDelegate
        delegate?.videoMessageCell(self, didClickImageWith: message)
    }
}
