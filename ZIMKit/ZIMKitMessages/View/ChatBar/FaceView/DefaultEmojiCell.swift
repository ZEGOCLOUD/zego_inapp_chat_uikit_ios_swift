//
//  DefaultEmojiCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/12.
//

import Foundation

protocol DefaultEmojiCellDelegate: AnyObject {
    func defaultEmojiCellClicked(with emoji: String)
}

class DefaultEmojiCell: _CollectionViewCell {

    static let reuseIdentifier = String(describing: DefaultEmojiCell.self)

    weak var delegate: DefaultEmojiCellDelegate?

    lazy var emojiLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30)
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        label.addGestureRecognizer(tap)
        contentView.addSubview(label)
        return label
    }()

    override func setUp() {
        super.setUp()
        contentView.backgroundColor = .clear
    }

    override func setUpLayout() {
        super.setUpLayout()
        embed(emojiLabel)
    }

    @objc func tap(_ t: UITapGestureRecognizer) {
        delegate?.defaultEmojiCellClicked(with: emojiLabel.text ?? "")
    }
}

// MARK: - Public
extension DefaultEmojiCell {
    func fillData(_ text: String) {
        emojiLabel.text = text
    }
}
