//
//  GalleryVC.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/25.
//

import Foundation
import Photos
import AssetsLibrary
import SwiftUI

class GalleryVC: _ViewController {

    struct Content {
        public var messages: [Message]
        public var currentMessage: Message
        public var currentIndex: Int

        public init(messages: [Message], currentMessage: Message, index: Int) {
            self.messages = messages
            self.currentMessage = currentMessage
            self.currentIndex = index
        }
    }

    var content: Content! {
        didSet {
            updateContentIfNeeded()
        }
    }

    var items: [Message] {
        let msgs = content.messages.filter({ $0.type == .image })
        return msgs
    }

    var transitionController: ZoomTransitionController!

    private(set) lazy var bottomBarView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .clear
        return view
    }()

    private(set) lazy var downloadButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setTitle(L10n("album_download_image"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .zim_backgroundBlue1
        button.layer.cornerRadius = 12.0
        button.addTarget(self, action: #selector(downloadButtonClick(_:)), for: .touchUpInside)
        return button
    }()

    private(set) lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }()

    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).withoutAutoresizingMaskConstraints
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageGalleryCell.self, forCellWithReuseIdentifier: ImageGalleryCell.reuseId)
        return collectionView
    }()

    override func setUp() {
        super.setUp()

        view.backgroundColor = .black

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }

    override func setUpLayout() {
        super.setUpLayout()

        view.embed(collectionView)

        view.addSubview(bottomBarView)
        bottomBarView.pin(anchors: [.leading, .trailing, .bottom], to: view)

        bottomBarView.addSubview(downloadButton)
        NSLayoutConstraint.activate([
            downloadButton.leadingAnchor.pin(equalTo: bottomBarView.leadingAnchor, constant: 16.0),
            downloadButton.trailingAnchor.pin(equalTo: bottomBarView.trailingAnchor, constant: -16.0),
            downloadButton.topAnchor.pin(equalTo: bottomBarView.topAnchor, constant: 8.5),
            downloadButton.heightAnchor.pin(equalToConstant: 44.0),
            downloadButton.bottomAnchor.pin(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8.5)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.reloadData()
        view.layoutIfNeeded()
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(
                at: .init(item: self.content.currentIndex, section: 0),
                at: .centeredHorizontally,
                animated: false)
        }
    }

    override func updateContent() {
        super.updateContent()


    }

    @objc func downloadButtonClick(_ sender: UIButton) {
        guard let message = content.currentMessage as? ImageMessage else { return }
        HUDHelper.showLoading(L10n("album_downloading_txt"))

        let url = message.fileDownloadUrl.count > 0
            ? message.fileDownloadUrl
            : message.fileLocalPath

        ImageDownloader.downloadImage(with: url) { data, image in
            if data == nil && image == nil {
                HUDHelper.showMessage(L10n("album_save_fail"))
                return
            }

            AuthorizedCheck.takePhotoAuthorityStatus { status in
                switch status {
                case .denied:
                    HUDHelper.dismiss()
                    AuthorizedCheck.showPhotoUnauthorizedAlert(self)
                case .authorized, .limited:
                    var data = data
                    if data == nil {
                        data = image?.data()
                    }
                    if data == nil {
                        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                    } else {
                        try? PHPhotoLibrary.shared().performChangesAndWait {
                            let request = PHAssetCreationRequest.forAsset()
                            request.addResource(with: .photo, data: data!, options: nil)
                        }
                    }

                    HUDHelper.showMessage(L10n("album_save_success"))
                default:
                    HUDHelper.showMessage(L10n("album_save_fail"))
                }
            }
        }
    }

    @objc func handlePan(with gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            transitionController.isInteractive = true
            dismiss(animated: true, completion: nil)
        case .ended:
            guard transitionController.isInteractive else { return }
            transitionController.isInteractive = false
            transitionController.handlePan(with: gestureRecognizer)
        default:
            guard transitionController.isInteractive else { return }
            transitionController.handlePan(with: gestureRecognizer)
        }
    }

    @objc func handleSingleTapOnCell(at indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
    }

    func updateCurrentPage() {
        content.currentIndex = Int(collectionView.contentOffset.x + collectionView.bounds.width / 2) / Int(collectionView.bounds.width)
        content.currentMessage = items[content.currentIndex]
    }

    /// Returns an image view to animate during interactive dismissing.
    var imageViewToAnimateWhenDismissing: UIImageView? {
        let cell = collectionView.visibleCells.first as? ImageGalleryCell
        return cell?.imageView
    }
}

extension GalleryVC: UICollectionViewDataSource,
                     UICollectionViewDelegate,
                     UICollectionViewDelegateFlowLayout,
                     UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageGalleryCell.reuseId, for: indexPath) as? ImageGalleryCell else {
            return UICollectionViewCell()
        }

        if indexPath.row >= items.count { return cell }

        cell.message = items[indexPath.row]

        cell.didTapOnce = { [weak self] in
            self?.handleSingleTapOnCell(at: indexPath)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }

    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        CGPoint(x: CGFloat(content.currentIndex) * collectionView.bounds.width,
                y: proposedContentOffset.y)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPage()
    }
}
