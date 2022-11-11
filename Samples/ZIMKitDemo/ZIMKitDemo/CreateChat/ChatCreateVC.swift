//
//  ChatCreateVC.swift
//  ZIMKitGroup
//
//  Created by Kael Ding on 2022/7/29.
//

import UIKit
import ZIMKit

enum CreateChatType {
    case single
    case group
    case join
}

class ChatCreateVC: UIViewController, UITextFieldDelegate {
    public convenience init(_ type: CreateChatType) {
        self.init()
        self.type = type
    }

    var type: CreateChatType = .single
    
    var userID: String = ""
    var groupID: String = ""
    var groupName: String = ""
    var groupUserIDs: [String] = []

    lazy var userIDField: UITextField = {
        let textField = UITextField().withoutAutoresizingMaskConstraints
        textField.backgroundColor = .zim_backgroundGray1
        var placeholder = LocalizedStr("message_input_user_id")
        if type == .join {
            placeholder = LocalizedStr("group_input_group_id")
        } else if type == .group {
            placeholder = LocalizedStr("group_input_user_id_of_group")
        }
        let attributed: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.zim_textGray1, .font: UIFont.systemFont(ofSize: 16)]
        let attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributed)
        textField.attributedPlaceholder = attributedPlaceholder
        textField.textColor = .zim_textBlack1
        textField.layer.cornerRadius = 8.0
        textField.keyboardType = .asciiCapable
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 16)

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(userIDFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()

    lazy var groupNameField: UITextField = {
        let textField = UITextField().withoutAutoresizingMaskConstraints
        textField.backgroundColor = .zim_backgroundGray1
        let attributed: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.zim_textGray1, .font: UIFont.systemFont(ofSize: 16)]
        let attributedPlaceholder = NSAttributedString(string: LocalizedStr("group_input_group_name"), attributes: attributed)
        textField.attributedPlaceholder = attributedPlaceholder
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .zim_textBlack1
        textField.layer.cornerRadius = 8.0

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(groupNameFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()

    lazy var tipLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.text = LocalizedStr("group_input_user_id_error_tip")
        label.textColor = .zim_textRed
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setTitle(LocalizedStr("group_create_chat"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.zim_textWhite, for: .normal)
        button.layer.cornerRadius = 8.0
        button.clipsToBounds = true
        button.setBackgroundImage(UIImage.image(with: .zim_backgroundBlue1), for: .normal)
        button.setBackgroundImage(UIImage.image(with: .zim_backgroundBlue1.withAlphaComponent(0.5)), for: .disabled)
        button.addTarget(self, action: #selector(actionButtonClick), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        updateContent()
    }

    func setUp() {
        
        view.backgroundColor = .zim_backgroundWhite

        let leftButton = UIButton(type: .custom)
        leftButton.setImage(UIImage(named: "group_bar_close"), for: .normal)
        leftButton.addTarget(self, action: #selector(leftBarButtonClick(_:)), for: .touchUpInside)
        leftButton.imageView?.contentMode = .scaleAspectFit
        leftButton.frame = CGRect(x: -15, y: 0, width: 44, height: 44)

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 44.0, height: 44.0))
        view.addSubview(leftButton)
        let leftItem = UIBarButtonItem(customView: view)
        navigationItem.leftBarButtonItem = leftItem

        switch type {
        case .single:
            navigationItem.title = LocalizedStr("message_create_single_chat")
        case .group:
            navigationItem.title = LocalizedStr("group_create_group_chat_title")
        case .join:
            navigationItem.title = LocalizedStr("group_join_group_chat")
        }
        
        groupNameField.isHidden = type != .group
    }

    func updateContent() {
        
        view.addSubview(groupNameField)
        NSLayoutConstraint.activate([
            groupNameField.topAnchor.pin(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44.0),
            groupNameField.leftAnchor.pin(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32.0),
            groupNameField.rightAnchor.pin(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32.0),
            groupNameField.heightAnchor.pin(equalToConstant: 50.0)
        ])

        view.addSubview(userIDField)
        userIDField.pin(anchors: [.left, .right, .height], to: groupNameField)
        let userIDTopConstraint = userIDField.topAnchor.pin(equalTo: view.safeAreaLayoutGuide.topAnchor)
        userIDTopConstraint.isActive = true
        if type == .group {
            userIDTopConstraint.constant = 106.0
        } else {
            userIDTopConstraint.constant = 64.0
        }

        view.addSubview(tipLabel)
        NSLayoutConstraint.activate([
            tipLabel.topAnchor.pin(equalTo: userIDField.bottomAnchor, constant: 8.0),
            tipLabel.leftAnchor.pin(equalTo: userIDField.leftAnchor, constant: 16.0),
            tipLabel.rightAnchor.pin(equalTo: userIDField.rightAnchor, constant: -16.0)
//            tipLabel.heightAnchor.pin(equalToConstant: 16.5)
        ])

        view.addSubview(actionButton)
        actionButton.pin(anchors: [.left, .right, .height], to: groupNameField)
        actionButton.topAnchor.pin(equalTo: tipLabel.bottomAnchor, constant: 16.0).isActive = true
    }

    @objc func leftBarButtonClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func actionButtonClick(_ sender: UIButton) {
        switch type {
        case .single:
            showMessageListVC(conversationID: userID, type: .peer)
            removeSelfVCFromNav()
        case .group:
            ZIMKitManager.shared.createGroup(groupName: groupName, userIDs: groupUserIDs) { [weak self] info, userErrors, error in
                if error.code != .success {
                    HUDHelper.showMessage(error.message)
                    return
                }
                if userErrors.count > 0 {
                    var userIDs = ""
                    for (i, errorInfo) in userErrors.enumerated() {
                        userIDs.append("\(errorInfo.userID),")
                        if i == 2 { break }
                    }
                    userIDs.removeLast()
                    if userErrors.count > 3 {
                        userIDs += "..."
                    }
                    let msg = LocalizedStr("group_group_user_id_not_exit", userIDs)
                    let alert = UIAlertController(title: LocalizedStr("group_user_not_exit"), message: msg, preferredStyle: .alert)
                    let action = UIAlertAction(title: LocalizedStr("common_sure"), style: .default)
                    alert.addAction(action)
                    self?.present(alert, animated: true)
                    return
                }
                // success
                self?.showMessageListVC(conversationID: info.id, type: .group, conversationName: info.name)
                self?.removeSelfVCFromNav()
            }
        case .join:
            ZIMKitManager.shared.joinGroup(by: groupID) { [weak self] info, error in
                if error.code == .success {
                    self?.showMessageListVC(conversationID: info.id, type: .group, conversationName: info.name)
                    self?.removeSelfVCFromNav()
                } else if error.code == .groupModuleGroupDoseNotExist {
                    let alert = UIAlertController(title: nil, message: LocalizedStr("group_group_not_exit"), preferredStyle: .alert)
                    let action = UIAlertAction(title: LocalizedStr("common_sure"), style: .default)
                    alert.addAction(action)
                    self?.present(alert, animated: true)
                } else {
                    if error.code == .groupModuleMemberIsAlreadyInTheGroup {
                        HUDHelper.showMessage(LocalizedStr("group_repeat_join_group_chat"))
                    } else {
                        HUDHelper.showMessage(error.message)
                    }
                }
            }
        }
    }

    @objc func userIDFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        if type == .single {
            userID = text
            actionButton.isEnabled = text.count >= 6 && text.count <= 12
            tipLabel.isHidden = actionButton.isEnabled
            if userID.count == 0 {
                tipLabel.isHidden = true
            }
        } else if type == .group {

            var invalid = false
            let userIds = text.components(separatedBy: ";")
            for id in userIds {
                if id.count < 6 || id.count > 12 {
                    invalid = true
                    break
                }
            }

            if invalid == false {
                groupUserIDs = userIds
            } else {
                groupUserIDs = []
            }
            tipLabel.isHidden = groupUserIDs.count > 0 || text.count == 0

            actionButton.isEnabled = groupUserIDs.count > 0 && groupName.count > 0

        } else if type == .join {
            groupID = text
            actionButton.isEnabled = text.count > 0
        }
    }

    @objc func groupNameFieldDidChange(_ textField: UITextField) {
        var text = textField.text ?? ""
        if text.count > 12 {
            text = String(text.prefix(12))
            textField.text = text
        }
        groupName = text
        actionButton.isEnabled = text.count > 0 && groupUserIDs.count > 0
    }

    func removeSelfVCFromNav() {
        guard var vcs = self.navigationController?.viewControllers else { return }
        vcs = vcs.filter({ !$0.isKind(of: ChatCreateVC.self) })
        self.navigationController?.viewControllers = vcs
    }
    
    func showMessageListVC(conversationID: String,
                           type: ConversationType,
                           conversationName: String = "") {
        let messageVC = MessagesListVC(conversationID: conversationID, type: type, conversationName: conversationName)
        self.navigationController?.pushViewController(messageVC, animated: true)
    }
}
