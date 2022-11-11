//
//  ImageGalleryCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/26.
//

import Foundation
import simd

class ImageGalleryCell: GalleryCollectionViewCell {
    class var reuseId: String { String(describing: self) }

    private(set) lazy var imageView: AnimatedImageView = {
        let imageView = AnimatedImageView().withoutAutoresizingMaskConstraints
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var imageWithConstraint: NSLayoutConstraint!
    private var imageHeightConstraint: NSLayoutConstraint!

    override func setUpLayout() {
        super.setUpLayout()

        scrollView.addSubview(imageView)
        //        imageView.pin(to: scrollView)

        imageWithConstraint = imageView.widthAnchor.pin(equalTo: contentView.widthAnchor)
        imageHeightConstraint = imageView.heightAnchor.pin(equalTo: contentView.heightAnchor)
        NSLayoutConstraint.activate([imageWithConstraint, imageHeightConstraint])
    }

    override func updateContent() {
        super.updateContent()

        guard let message = message as? ImageMessage else { return }

        imageWithConstraint.isActive = false
        imageHeightConstraint.isActive = false

        let width = contentView.bounds.width
        var height = width * message.originalImageSize.height / message.originalImageSize.width
        if height < contentView.bounds.height {
            height = contentView.bounds.height
        }
        if height.isNaN {
            height = contentView.bounds.height
        }

        if height > contentView.bounds.height+1.0 {
            imageView.contentMode = .scaleAspectFill
        } else {
            imageView.contentMode = .scaleAspectFit
        }

        updateImageViewConstraints(width: width, height: height)

        let isResize = !message.isGif && message.fileSize > 5 * 1024 * 1024

        ImageCache.cachedImage(
            for: message.thumbnailDownloadUrl,
            isResize: isResize
        ) { [weak self] image in

            let url = message.largeImageDownloadUrl.count > 0
                ? message.largeImageDownloadUrl
                : message.fileLocalPath

            let placeholder = image != nil
                ? image
                : loadImageSafely(with: "chat_image_fail_bg")

            self?.imageView.loadImage(
                with: url,
                placeholder: placeholder,
                isResize: false
            ) { [weak self] result in
                if case .failure = result {
                    self?.imageView.contentMode = .scaleAspectFit
                    let h = self?.contentView.bounds.height ?? 0
                    self?.updateImageViewConstraints(width: width, height: h)
                } else {
                    self?.updateImageViewConstraints(width: width, height: height)
                }
            }
        }
    }

    func updateImageViewConstraints(width: CGFloat, height: CGFloat) {

        imageWithConstraint.isActive = false
        imageHeightConstraint.isActive = false

        imageWithConstraint = imageView.widthAnchor.pin(equalToConstant: width)
        imageHeightConstraint = imageView.heightAnchor.pin(equalToConstant: height)
        NSLayoutConstraint.activate([imageWithConstraint, imageHeightConstraint])

        let contentHeight = height < contentView.bounds.height+1.0 ? 0.0 : height
        scrollView.contentSize = CGSize(width: 0, height: contentHeight)
    }

    override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
