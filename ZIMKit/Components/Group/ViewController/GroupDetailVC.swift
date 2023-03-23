//
//  ConversationListVC.swift
//  ZIMKitConversation
//
//  Created by Kael Ding on 2022/7/29.
//

import UIKit

class GroupDetailVC: _ViewController {
    public convenience init(_ groupID: String, _ groupName: String) {
        self.init()
        self.groupID = groupID
        self.groupName = groupName
    }

    var groupID: String!
    var groupName: String!

    lazy var contentView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundWhite
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        return view
    }()

    lazy var leftLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.text = L10n("group_group_id")
        label.textColor = .zim_textBlack1
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        return label
    }()

    lazy var copyLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.text = L10n("group_copy")
        label.textColor = .zim_textGray5
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    lazy var idLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.text = groupID
        label.textColor = .zim_textGray6
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .right
        return label
    }()

    override func setUp() {
        super.setUp()
        view.backgroundColor = .zim_backgroundGray1
        navigationItem.title = groupName

        let leftButton = UIButton(type: .custom)
        leftButton.setImage(loadImageSafely(with: "chat_nav_left"), for: .normal)
        leftButton.addTarget(self, action: #selector(backItemClick(_:)), for: .touchUpInside)
        leftButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        let leftItem = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftItem

        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        contentView.addGestureRecognizer(tap)
    }

    override func setUpLayout() {
        super.setUpLayout()

        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.pin(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            contentView.leadingAnchor.pin(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            contentView.trailingAnchor.pin(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8.0),
            contentView.heightAnchor.pin(equalToConstant: 48.0)
        ])

        contentView.addSubview(leftLabel)
        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.pin(equalTo: contentView.leadingAnchor, constant: 16.0),
            leftLabel.centerYAnchor.pin(equalTo: contentView.centerYAnchor),
            leftLabel.heightAnchor.pin(equalToConstant: 22.0)
        ])

        contentView.addSubview(copyLabel)
        NSLayoutConstraint.activate([
            copyLabel.trailingAnchor.pin(equalTo: contentView.trailingAnchor, constant: -16.0),
            copyLabel.centerYAnchor.pin(equalTo: contentView.centerYAnchor),
            copyLabel.heightAnchor.pin(equalToConstant: 22.0)
        ])

        contentView.addSubview(idLabel)
        NSLayoutConstraint.activate([
            idLabel.trailingAnchor.pin(equalTo: copyLabel.leadingAnchor, constant: -16.0),
            idLabel.centerYAnchor.pin(equalTo: contentView.centerYAnchor),
            idLabel.heightAnchor.pin(equalToConstant: 22.0)
        ])
    }

    override func updateContent() {
        super.updateContent()

    }

    @objc func backItemClick(_ btn: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        UIPasteboard.general.string = groupID
        HUDHelper.showMessage(L10n("group_copy_success"))
    }
}
