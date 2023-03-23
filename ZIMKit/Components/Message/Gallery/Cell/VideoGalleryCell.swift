//
//  VideoGalleryCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/26.
//

import Foundation

class VideoGalleryCell: GalleryCollectionViewCell {
    /// A cell reuse identifier.
    class var reuseId: String { String(describing: self) }

    private(set) lazy var animationPlaceholderImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func setUpLayout() {
        super.setUpLayout()

    }

    override func updateContent() {
        super.updateContent()

    }

    override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        animationPlaceholderImageView
    }
}
