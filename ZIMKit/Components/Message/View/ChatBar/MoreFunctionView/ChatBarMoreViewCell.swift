//
//  ChatBarMoreViewCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/15.
//

import Foundation

class ChatBarMoreViewCell: _CollectionViewCell {

    static let reuseIdentifier = String(describing: ChatBarMoreViewCell.self)

    lazy var imageBackgroundView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = .zim_backgroundWhite
        return view
    }()

    lazy var imageView = UIImageView().withoutAutoresizingMaskConstraints

    lazy var label: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.font = UIFont.systemFont(ofSize: 11)
        label.textAlignment = .center
        label.textColor = .zim_textGray4
        return label
    }()

    override func setUp() {
        super.setUp()
    }

    override func setUpLayout() {
        super.setUpLayout()
        contentView.addSubview(imageBackgroundView)
        imageBackgroundView.addSubview(imageView)
        contentView.addSubview(label)

        imageBackgroundView.pin(to: 58.0)
        imageBackgroundView.pin(anchors: [.centerX], to: contentView)
        imageBackgroundView.topAnchor.pin(
            equalTo: contentView.topAnchor,
            constant: 8)
            .isActive = true

        imageView.pin(anchors: [.centerX, .centerY], to: imageBackgroundView)
        imageView.pin(to: 34.0)

        NSLayoutConstraint.activate([
            label.centerXAnchor.pin(equalTo: contentView.centerXAnchor),
            label.topAnchor.pin(equalTo: imageBackgroundView.bottomAnchor, constant: 8),
            label.heightAnchor.pin(equalToConstant: 15.0)
        ])
    }
}

extension ChatBarMoreViewCell {
    func fillData(_ data: ChatBarMoreModel) {
        label.text = data.title
        imageView.image = loadImageSafely(with: data.icon)
    }
}
