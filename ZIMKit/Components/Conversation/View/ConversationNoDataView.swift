//
//  ConversationNoDataView.swift
//  ZIMKitConversation
//
//  Created by Kael Ding on 2022/8/4.
//

import Foundation
import UIKit

protocol ConversationNoDataViewDelegate: AnyObject {
    func onNoDataViewButtonClick()
}

class ConversationNoDataView: _View {

    weak var delegate: ConversationNoDataViewDelegate?

    lazy var titleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .zim_textGray1
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.text = L10n("conversation_empty")
        return label
    }()

    lazy var createButton: UIButton = {
        let btn = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        btn.setTitle(L10n("conversation_reload"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        btn.setTitleColor(.zim_textWhite, for: .normal)
        btn.backgroundColor = .zim_backgroundBlue1
        btn.layer.cornerRadius = 8.0
        btn.addTarget(self, action: #selector(createButtonClick(_:)), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()

    override func setUp() {
        super.setUp()
    }

    override func setUpLayout() {
        super.setUpLayout()

        addSubview(titleLabel)
        addSubview(createButton)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.pin(equalTo: centerXAnchor),
            titleLabel.topAnchor.pin(equalTo: safeAreaLayoutGuide.topAnchor, constant: 200.0),
            titleLabel.heightAnchor.pin(equalToConstant: 40.0)
        ])

        NSLayoutConstraint.activate([
            createButton.leadingAnchor.pin(equalTo: leadingAnchor, constant: 37),
            createButton.trailingAnchor.pin(equalTo: trailingAnchor, constant: -37),
            createButton.bottomAnchor.pin(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -44),
            createButton.heightAnchor.pin(equalToConstant: 50)
        ])
    }

    func setButtonTitle(_ title: String) {
        createButton.setTitle(title, for: .normal)
        titleLabel.isHidden = true
    }
}

extension ConversationNoDataView {
    @objc func createButtonClick(_ sender: UIButton) {
        delegate?.onNoDataViewButtonClick()
    }
}
