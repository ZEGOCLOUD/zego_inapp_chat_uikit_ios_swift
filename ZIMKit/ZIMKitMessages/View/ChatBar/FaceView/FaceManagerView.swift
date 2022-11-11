//
//  FaceManagerView.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/11.
//

import Foundation
import UIKit

protocol FaceManagerViewDelegate: AnyObject {
    func faceViewDidSelectDefaultEmoji(_ emoji: String)
    func faceViewDidDeleteButtonClicked()
    func faceViewDidSendButtonClicked()
}

class FaceManagerView: _View {

    weak var delegate: FaceManagerViewDelegate?

    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
            .withoutAutoresizingMaskConstraints
        collectionView.backgroundColor = .zim_backgroundGray2
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.isPagingEnabled = true
        collectionView.register(DefaultEmojiCollectionView.self,
                                forCellWithReuseIdentifier: DefaultEmojiCollectionView.reuseIdentifier)
        return collectionView
    }()

    var collectionHeightConstraint: NSLayoutConstraint!

    override func setUp() {
        super.setUp()
        backgroundColor = .zim_backgroundGray2
    }

    override func setUpLayout() {
        super.setUpLayout()
        addSubview(collectionView)
        collectionView.pin(anchors: [.leading, .trailing, .top], to: self)
        collectionHeightConstraint = collectionView.heightAnchor.pin(equalToConstant: 250.0)
        collectionHeightConstraint.isActive = true
    }

    override func updateContent() {
        super.updateContent()

    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        collectionHeightConstraint.constant = 250 + safeAreaInsets.bottom
    }
}

// MARK: - Public
extension FaceManagerView {
    func updateCurrentTextViewContent(_ text: String) {
        if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? DefaultEmojiCollectionView {
            cell.deleteButton.isEnabled = text.count > 0
            cell.sendButton.isEnabled = text.count > 0
        }
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout
extension FaceManagerView:  UICollectionViewDataSource,
                            UICollectionViewDelegate,
                            UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DefaultEmojiCollectionView.reuseIdentifier,
                for: indexPath) as? DefaultEmojiCollectionView else {
            return DefaultEmojiCollectionView()
        }
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension FaceManagerView: DefaultEmojiCollectionViewDelegate {
    func defaultEmojiCollectionViewDidSelectItem(with emoji: String) {
        delegate?.faceViewDidSelectDefaultEmoji(emoji)
    }

    func defaultEmojiCollectionViewDidDeleteButtonClicked() {
        delegate?.faceViewDidDeleteButtonClicked()
    }

    func defaultEmojiCollectionViewDidSendButtonClicked() {
        delegate?.faceViewDidSendButtonClicked()
    }
}
