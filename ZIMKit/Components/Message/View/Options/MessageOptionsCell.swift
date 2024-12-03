//
//  MessageOptionsCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/26.
//

import Foundation

class MessageOptionsCell: _CollectionViewCell {

    static let reuseId = String(describing: MessageOptionsCell.self)

    lazy var iconImageView = UIImageView().withoutAutoresizingMaskConstraints
    lazy var titleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .zim_textWhite
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.numberOfLines = 2
        return label
    }()

    override func setUp() {
        super.setUp()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    override func setUpLayout() {
        super.setUpLayout()

        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)

        iconImageView.pin(to: 28)
        iconImageView.topAnchor.pin(equalTo: contentView.topAnchor, constant: 0).isActive = true
        iconImageView.centerXAnchor.pin(equalTo: contentView.centerXAnchor).isActive = true

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.pin(equalTo: iconImageView.bottomAnchor, constant: 1.0),
            titleLabel.centerXAnchor.pin(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.pin(equalTo: contentView.leadingAnchor, constant: 0),
            titleLabel.trailingAnchor.pin(equalTo: contentView.trailingAnchor, constant: 0)
            //            titleLabel.heightAnchor.pin(equalToConstant: 14.0)
        ])
    }

    override func updateContent() {
        super.updateContent()

    }

    func setupContent(_ content: MessageOptionsView.Content) {

        iconImageView.image = loadImageSafely(with: content.icon)
        titleLabel.text = content.title
    }
}
