//
//  DefaultEmojiCollectionView.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/12.
//

import Foundation
import UIKit

protocol DefaultEmojiCollectionViewDelegate: AnyObject {
    func defaultEmojiCollectionViewDidSelectItem(with emoji: String)
    func defaultEmojiCollectionViewDidDeleteButtonClicked()
    func defaultEmojiCollectionViewDidSendButtonClicked()
}

class DefaultEmojiCollectionView: _CollectionViewCell {

    static let reuseIdentifier = String(describing: DefaultEmojiCollectionView.self)

    weak var delegate: DefaultEmojiCollectionViewDelegate?

    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        //        layout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        return layout
    }()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: bounds,
            collectionViewLayout: flowLayout)
            .withoutAutoresizingMaskConstraints
        collectionView.backgroundColor = .zim_backgroundGray2
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.bounces = true
        // below iOS 13, the `contentInset` will reload the collection view,
        // so we should register cell first, to avoid the crash.
        collectionView.register(DefaultEmojiCell.self,
                                forCellWithReuseIdentifier: DefaultEmojiCell.reuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 16*2+15, right: 15)
        return collectionView
    }()

    lazy var buttonBackgroundView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundGray2.withAlphaComponent(0.95)
        return view
    }()

    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.layer.cornerRadius = 4.0
        button.layer.masksToBounds = true
        button.setImage(loadImageSafely(with: "chat_face_delete"), for: .normal)
        button.setImage(loadImageSafely(with: "chat_face_delete_disabled"), for: .disabled)
        button.addTarget(self, action: #selector(deleteButtonClick(_:)), for: .touchUpInside)
        button.backgroundColor = .zim_textWhite
        button.isEnabled = false
        return button
    }()

    lazy var sendButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.layer.cornerRadius = 4.0
        button.layer.masksToBounds = true
        button.setTitleColor(.zim_textWhite, for: .normal)
        button.setTitleColor(.zim_textGray3, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.titleLabel?.textAlignment = .center
        button.setTitle(L10n("message_send"), for: .normal)
        button.addTarget(self, action: #selector(sendButtonClick(_:)), for: .touchUpInside)
        button.setBackgroundImage(UIImage.image(with: .zim_backgroundBlue1), for: .normal)
        button.setBackgroundImage(UIImage.image(with: .zim_backgroundWhite), for: .disabled)
        button.isEnabled = false
        return button
    }()

    lazy var emojiList: [String] = ["😀", "😃", "😄", "😁", "😆", "😅", "😂",
                                    "😇", "😉", "😊", "😋", "😌", "😍", "😘",
                                    "😗", "😙", "😚", "😜", "😝", "😛", "😎",
                                    "😏", "😶", "😐", "😑", "😒", "😳", "😞",
                                    "😟", "😤", "😠", "😡", "😔", "😕", "😬",
                                    "😣", "😖", "😫", "😩", "😪", "😮", "😱",
                                    "😨", "😰", "😥", "😓", "😯", "😦", "😧",
                                    "😢", "😭", "😵", "😲", "😷", "😴", "💤",
                                    "😈", "👿", "👹", "👺", "💩", "👻", "💀",
                                    "👽", "🎃", "😺", "😸", "😹", "😻", "😼",
                                    "😽", "🙀", "😿", "😾", "👐", "🙌", "👏",
                                    "🙏", "👍", "👎", "👊", "✊", "👌", "👈",
                                    "👉", "👆", "👇", "✋", "👋", "💪", "💅",
                                    "👄", "👅", "👂", "👃", "👀", "👶", "👧",
                                    "👦", "👩", "👨", "👱", "👵", "👴", "👲",
                                    "👳‍", "👼", "👸", "👰", "🙇", "💁", "🙅‍",
                                    "🙆", "🙋", "🙎", "🙍", "💇", "💆", "💃",
                                    "👫", "👭", "👬", "💛", "💚", "💙", "💜",
                                    "💔", "💕", "💞", "💓", "💗", "💖", "💘",
                                    "💝", "💟"]

    var buttonBackgroundHeightConstraint: NSLayoutConstraint!

    override func setUp() {
        super.setUp()
        contentView.backgroundColor = .zim_backgroundGray2
    }

    override func setUpLayout() {
        super.setUpLayout()

        contentView.addSubview(collectionView)
        contentView.addSubview(buttonBackgroundView)
        buttonBackgroundView.addSubview(deleteButton)
        buttonBackgroundView.addSubview(sendButton)

        collectionView.pin(to: self)

        buttonBackgroundView.pin(anchors: [.trailing, .bottom], to: self)
        buttonBackgroundView
            .widthAnchor.pin(
                equalToConstant: bounds.width * 3.0 / 7.0)
            .isActive = true
        buttonBackgroundHeightConstraint = buttonBackgroundView
            .heightAnchor.pin(
                equalToConstant: 98+safeAreaInsets.bottom)
        buttonBackgroundHeightConstraint.isActive = true

        NSLayoutConstraint.activate([
            sendButton.topAnchor.pin(
                equalTo: buttonBackgroundView.topAnchor,
                constant: 28),
            sendButton.trailingAnchor.pin(
                equalTo: buttonBackgroundView.trailingAnchor,
                constant: -16),
            sendButton.widthAnchor.pin(equalToConstant: 54),
            sendButton.heightAnchor.pin(equalToConstant: 42)
        ])

        deleteButton.pin(anchors: [.top, .width, .height], to: sendButton)
        deleteButton
            .trailingAnchor.pin(
                equalTo: sendButton.leadingAnchor,
                constant: -12)
            .isActive = true
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        buttonBackgroundHeightConstraint.constant = 98+safeAreaInsets.bottom
    }
}

// MARK: - Actions
extension DefaultEmojiCollectionView {
    @objc func deleteButtonClick(_ sender: UIButton) {
        delegate?.defaultEmojiCollectionViewDidDeleteButtonClicked()
    }

    @objc func sendButtonClick(_ sender: UIButton) {
        delegate?.defaultEmojiCollectionViewDidSendButtonClicked()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout
extension DefaultEmojiCollectionView:   UICollectionViewDataSource,
                                        UICollectionViewDelegate,
                                        UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DefaultEmojiCell.reuseIdentifier, for: indexPath) as? DefaultEmojiCell else {
            return DefaultEmojiCell()
        }
        if indexPath.row >= emojiList.count {
            return DefaultEmojiCell()
        }
        cell.delegate = self
        cell.fillData(emojiList[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (bounds.width - 2 * 15.0 - 6 * 5.0) / 7.0
        return CGSize(width: width, height: width)
    }
}

extension DefaultEmojiCollectionView: DefaultEmojiCellDelegate {
    func defaultEmojiCellClicked(with emoji: String) {
        delegate?.defaultEmojiCollectionViewDidSelectItem(with: emoji)
    }
}
