//
//  GalleryCollectionViewCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/26.
//

import Foundation

class GalleryCollectionViewCell: _CollectionViewCell, UIScrollViewDelegate {

    var didTapOnce: (() -> Void)?

    var message: Message? {
        didSet {
            if superview != nil {
                updateContentIfNeeded()
            }
        }
    }

    private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView().withoutAutoresizingMaskConstraints
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    override func setUp() {
        super.setUp()

        let doubleTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleDoubleTapOnScrollView)
        )
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)

        let singleTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleSingleTapOnScrollView)
        )
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
    }

    override func setUpLayout() {
        super.setUpLayout()
        contentView.embed(scrollView)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        nil
    }

    /// Triggered when scroll view is double tapped.
    @objc open func handleDoubleTapOnScrollView() {
        if scrollView.zoomScale != scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale / 2, animated: true)
        }
    }

    /// Triggered when scroll view is single tapped.
    @objc open func handleSingleTapOnScrollView() {
        didTapOnce?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        didTapOnce = nil
        message = nil
    }
}
