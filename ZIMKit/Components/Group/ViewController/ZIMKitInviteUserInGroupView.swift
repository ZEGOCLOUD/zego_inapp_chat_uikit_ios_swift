//
//  ZIMKitPopView.swift
//  ZIMKit
//
//  Created by zego on 2024/7/26.
//

import UIKit

class ZIMKitInviteUserInGroupView: UIView {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .zim_textBlack1
        label.textAlignment = .center
        label.text = L10n("add_member_title")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .zim_textBlack1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField().withoutAutoresizingMaskConstraints
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor(hex: 0xF1F4F8).cgColor
        textField.layer.borderWidth = 1
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: L10n("enter_invite_member_placeholder"), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0x8E9093), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        textField.rightView = leftView
        textField.rightViewMode = .always
        
        return textField
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type:.system)
        button.setTitle(L10n("common_title_cancel"), for:.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(hex: 0x646A73), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let sureButton: UIButton = {
        let button = UIButton(type:.system)
        button.setTitle(L10n("common_sure"), for:.normal)
        button.setTitleColor(.black, for:.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(hex: 0x3478FC), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF1F4F8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var centerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF1F4F8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var groupID:String?
    var titleString:String = ""
    var detailString:String = ""
    var buttonCount:[String] = [L10n("common_title_cancel"),L10n("common_sure")]
    var alert:Bool = false
    var cancelBlock: (() -> Void)?
    var sureBlock: ((Bool) -> Void)?
    
    
    public init(conversationID: String) {
        super.init(frame:UIScreen.main.bounds)
        groupID = conversationID
        addSubviews()
    }
    
    func addSubviews() {
        backgroundColor = UIColor(hex: 0x000000, a: 0.4)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(inputTextField)
        containerView.addSubview(cancelButton)
        containerView.addSubview(sureButton)
        containerView.addSubview(dividerView)
        containerView.addSubview(centerLine)
        containerView.addSubview(detailLabel)
        
        inputTextField.isHidden = alert
        detailLabel.isHidden = !alert
        sureButton.isHidden = buttonCount.count != 2
        centerLine.isHidden = buttonCount.count != 2
        setupConstraints()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.addGestureRecognizer(tap)
        
        cancelButton.addTarget(self, action: #selector(cancelItemClick(_:)), for: .touchUpInside)
        sureButton.addTarget(self, action: #selector(sureItemClick(_:)), for: .touchUpInside)
        inputTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for:.editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.heightAnchor.pin(equalToConstant: (alert ? 130.0 : 160.0) / 270.0 * (UIScreen.main.bounds.width - 106)),
            containerView.widthAnchor.pin(equalToConstant: UIScreen.main.bounds.width - 106),
            
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            
            inputTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            inputTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            inputTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 13),
            inputTextField.heightAnchor.pin(equalToConstant: 46),
            
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            cancelButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: (alert && buttonCount.count == 1) ? 1 : 0.5),
            cancelButton.heightAnchor.pin(equalToConstant: 50),
            
            sureButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            sureButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            sureButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: (alert && buttonCount.count == 1) ? 1 : 0.5),
            sureButton.heightAnchor.pin(equalToConstant: 50),
            
            dividerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dividerView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            
            
            centerLine.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            centerLine.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            centerLine.widthAnchor.constraint(equalToConstant: 1),
            centerLine.heightAnchor.constraint(equalToConstant: 50),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 13),
            detailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            detailLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            detailLabel.heightAnchor.constraint(equalToConstant: 15),
        ])
    }
    
    func showView() {
        if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            self.alpha = 0
            keyWindow.addSubview(self)
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            } completion: { (finished) in
            }
        }
    }
    
    func hideView() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { (finished) in
            self.removeFromSuperview()
        }
    }
    
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.hideView()
    }
    
    @objc func cancelItemClick(_ button: UIButton) {
        self.hideView()
        self.cancelBlock?()
    }
    
    @objc func sureItemClick(_ button: UIButton) {
        
        let userString:String = inputTextField.text ?? ""
        guard let nonNilGroupID = groupID else {
            return
        }
        
        if userString.isEmpty {
            return
        }
        ZIMKit.inviteUsersIntoGroup(by: nonNilGroupID, userIDs: [userString]) { [weak self] groupID, userList, errorUserList, error in
            if error.code.rawValue == 0 {
                self?.hideView()
                HUDHelper.showMessage(L10n("invite_success"))
            } else if (error.code.rawValue == 6000011) {
                print("[ERROR] inviteUsersIntoGroup error: code = \(error.code)")
                HUDHelper.showErrorMessageIfNeeded(error.code.rawValue,
                                                   defaultMessage: L10n("user_not_register"))
                
            } else if error.code.rawValue == 6000522 {
                HUDHelper.showErrorMessageIfNeeded(error.code.rawValue,
                                                   defaultMessage: L10n("already_belong"))
            }
            self?.sureBlock?(error.code.rawValue == 0)
        }
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        
        if text.count <= 0 {
            sureButton.isEnabled = false
        } else {
            sureButton.isEnabled = true
        }
    }
}


