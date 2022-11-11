//
//  LoginViewController.swift
//  ZIMKitDemo
//
//  Created by Kael Ding on 2022/8/2.
//

import Foundation
import UIKit
import SnapKit
import ZIMKit

class LoginViewController: UIViewController {

    lazy var topBgView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "img_background")
        view.addSubview(imageView)
        return imageView
    }()

    lazy var topLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.minimumLineHeight = 35.0
        paragraphStyle.alignment = .left
        
        let attributes: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 23, weight: .medium),
                                                          .paragraphStyle : paragraphStyle,
                                                          .foregroundColor: UIColor.zim_textWhite]
        let attributedStr = NSAttributedString(string: LocalizedStr("demo_welcome"), attributes: attributes)
        label.attributedText = attributedStr
        
        view.addSubview(label)
        return label
    }()

    lazy var bottomBgView: UIView = {
        let bottomView = UIView()
        bottomView.backgroundColor = .white
        bottomView.layer.cornerRadius = 24.0
        view.addSubview(bottomView)
        return bottomView
    }()

    lazy var phoneLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedStr("demo_user_id_login")
        label.textColor = UIColor(hex: 0x2A2A2A)
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        bottomBgView.addSubview(label)
        return label
    }()

    lazy var textField: UITextField = {
        let t = UITextField()
        t.delegate = self
        t.layer.cornerRadius = 8.0
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        t.leftView = leftView
        t.leftViewMode = .always
        t.rightView = rightView
        t.rightViewMode = .always
        t.textColor = UIColor(hex: 0x2A2A2A)
        t.keyboardType = .asciiCapable
        t.placeholder = LocalizedStr("demo_input_user_id_error_tips")
        t.backgroundColor = UIColor(hex: 0xF2F2F2)
        t.font = .systemFont(ofSize: 16)
        t.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        bottomBgView.addSubview(t)
        return t
    }()

    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedStr("demo_input_user_id_error_tips")
        label.textColor = UIColor(hex: 0xFF4A50)
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.isHidden = true
        bottomBgView.addSubview(label)
        return label
    }()

    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedStr("demo_user_name", "")
        label.textColor = UIColor(hex: 0x2A2A2A)
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16.0)
        bottomBgView.addSubview(label)
        return label
    }()

    lazy var loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(LocalizedStr("demo_login"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        button.backgroundColor = UIColor(hex: 0x3478FC, a: 0.5)
        button.isEnabled = false
        button.layer.cornerRadius = 8.0
        button.addTarget(self, action: #selector(connectUserAction(_:)), for: .touchUpInside)
        bottomBgView.addSubview(button)
        return button
    }()

    lazy var userNames: [String] = {
        guard let path = Bundle.main.path(forResource: "user_name", ofType: "txt") else {
            return []
        }
        guard let nameStr = try? String(contentsOfFile: path, encoding: .utf8) else {
            return []
        }
        let names = nameStr.components(separatedBy: "\n")
        return names
    }()

    var userID: String = ""
    var userName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        configUI()

    }
}

extension LoginViewController {
    private func configUI() {

        view.backgroundColor = .white

        topBgView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(212)
        }

        topLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(86)
        }

        bottomBgView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view).offset(24)
            make.top.equalTo(topBgView.snp.bottom).offset(-22)
        }

        phoneLabel.snp.makeConstraints { make in
            make.left.equalTo(37)
            make.top.equalTo(40)
            make.height.equalTo(22.5)
        }

        textField.snp.makeConstraints { make in
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.top.equalTo(phoneLabel.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

        tipLabel.snp.makeConstraints { make in
            make.left.right.equalTo(textField)
            make.top.equalTo(textField.snp.bottom).offset(8)
            make.height.equalTo(0)
        }

        userNameLabel.snp.makeConstraints { make in
            make.left.equalTo(37)
            make.right.equalTo(-37)
            make.top.equalTo(tipLabel.snp.bottom).offset(8)
        }

        loginButton.snp.makeConstraints { make in
            make.left.equalTo(37)
            make.right.equalTo(-37)
            make.top.equalTo(userNameLabel.snp.bottom).offset(28)
            make.height.equalTo(50)
        }
    }

    private func updateConstraints() {
        tipLabel.snp.remakeConstraints { make in
            make.left.right.equalTo(textField)
            make.top.equalTo(textField.snp.bottom).offset(8)
            if tipLabel.isHidden {
                make.height.equalTo(0)
            }
        }
    }

    @objc func connectUserAction(_ sender: UIButton) {
        view.endEditing(true)
        let userInfo = UserInfo(userID, userName)
        userInfo.avatarUrl = getUserAvatar(userID)
        HUDHelper.showLoading()
        ZIMKitManager.shared.connectUser(userInfo: userInfo) { error in
            HUDHelper.dismiss()
            if error.code == .success {
                let conversationVC = DemoConversationListVC()
                let nav = NavigationController(rootViewController: conversationVC)

                let tab = ZegoTabBarController()
                tab.setupControllers([nav])

                UIApplication.key?.rootViewController = tab
            }

            else if error.code == .networkModuleNetworkError {
                HUDHelper.showMessage(LocalizedStr("demo_network_error_tip"))
            }

            else {
                HUDHelper.showMessage(error.message)
                self.tipLabel.isHidden = false
                self.updateConstraints()
            }
        }
    }

    @objc func textFieldDidChange(_ sender: UITextField) {

        let userID = sender.text ?? ""
        let isMatch = matchUserName(userID)
        tipLabel.isHidden = isMatch
        loginButton.isEnabled = isMatch
        loginButton.backgroundColor = isMatch ? UIColor(hex: 0x3478FC) : UIColor(hex: 0x3478FC, a: 0.5)

        let userName = getUserName(userID)
        userNameLabel.text = LocalizedStr("demo_user_name", userName)

        self.userID = userID
        self.userName = userName

        updateConstraints()
    }

    private func matchUserName(_ userName: String?) -> Bool {
        guard let userName = userName else {
            return false
        }
        return userName.count >= 6 && userName.count <= 12
    }

    private func getUserName(_ userID: String) -> String {
        if !matchUserName(userID) || userNames.count == 0 {
            return ""
        }
        let userKey = "user_name_key_" + userID
        let userDefaults = UserDefaults.standard
        if let userName = userDefaults.string(forKey: userKey) {
            return userName
        }
        let index = UInt32.random(in: 0..<UInt32(userNames.count))
        let userName = userNames[Int(index)]
        userDefaults.set(userName, forKey: userKey)
        return userName
    }

    private func getUserAvatar(_ userID: String) -> String {
        var index: UInt32 = 0
        if let firstChar = userID.unicodeScalars.first {
            index = firstChar.value
        }
        index = index % 9
        return String(format: "https://storage.zego.im/IMKit/avatar/avatar-%d.png", index)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let proposeLength = textField.text!.count - range.length + string.count
        if proposeLength > 12 {
            return false
        }
        return true
    }

}
