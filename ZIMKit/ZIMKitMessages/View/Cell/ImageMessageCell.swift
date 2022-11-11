//
//  ImageMessageCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/18.
//

import Foundation
import Kingfisher

protocol ImageMessageCellDelegate: MessageCellDelegate {
    func imageMessageCell(_ cell: ImageMessageCell, didClickImageWith message: ImageMessage)
}

class ImageMessageCell: MessageCell {
    override class var reuseId: String {
        String(describing: ImageMessageCell.self)
    }

    lazy var thumbnailImageView: AnimatedImageView = {
        let imageView = AnimatedImageView().withoutAutoresizingMaskConstraints
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        imageView.addGestureRecognizer(tap)
        containerView.addSubview(imageView)
        return imageView
    }()

    override func setUp() {
        super.setUp()
    }

    override func setUpLayout() {
        super.setUpLayout()
        updateImageConstraint()
    }

    private func updateImageConstraint() {
        let insets = message?.cellConfig.contentInsets ?? UIEdgeInsets()
        let directionInsets = NSDirectionalEdgeInsets(
            top: insets.top,
            leading: insets.left,
            bottom: insets.bottom,
            trailing: insets.right)
        thumbnailImageView.removeFromSuperview()
        containerView.embed(thumbnailImageView, insets: directionInsets)
    }

    override func updateContent() {
        super.updateContent()

        guard let message = message as? ImageMessage else { return }
        updateImageConstraint()

        let placeHolder = "chat_image_fail_bg"
        let path = message.thumbnailDownloadUrl.count > 0
            ? message.thumbnailDownloadUrl
            : message.fileLocalPath

        // if image size max than 5MB, will resize to avoiding memory issue.
        let isResize = !message.isGif && message.fileSize > 5 * 1024 * 1024
        let maxSize = CGSize(
            width: message.contentSize.width * 3,
            height: message.contentSize.height * 3)

        thumbnailImageView.loadImage(
            with: path,
            placeholder: placeHolder,
            maxSize: maxSize,
            isResize: isResize
        ) { [weak message] value in
            switch value {
            case .success:
                // remove the other caches.
                if path != message?.fileLocalPath,
                   let fileLocalPath = message?.fileLocalPath {
                    ImageCache.removeCache(for: fileLocalPath)
                }
            case .failure:
                break
            }
        }
    }
}

extension ImageMessageCell {
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        if let message = message as? ImageMessage {
            let delegate = delegate as? ImageMessageCellDelegate
            delegate?.imageMessageCell(self, didClickImageWith: message)
        }
    }
}
