//
//  ZIMKitMultipleForwardConfirmView.swift
//  ZIMKit
//
//  Created by zego on 2024/8/22.
//

import UIKit
import ZIM
protocol ForwardConversationDelegate: NSObjectProtocol {
    func didClickSendCombineMessage(conversation:ZIMKitConversation)
}


class ZIMKitMultipleForwardConfirmView: UIView {
    let containerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .zim_textBlack1
        label.text = L10n("send_message") + ":"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .zim_textBlack1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let forwardTypeView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = UIColor(hex: 0xF2F3F5)
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let forwardTypeLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hex: 0x646A73)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let conversationNameLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .zim_textBlack1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var conversationAvatar: UIImageView = {
        let imageView:UIImageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
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
    
    weak var delegate: ForwardConversationDelegate?
    var conversation: ZIMKitConversation?
    var conversationType: ZIMConversationType = .peer
    var combineConversationName: String = ""
    var forwardType: forwardMessageType = .forward
    
    public init(conversation:ZIMKitConversation,
                conversationType: ZIMConversationType,
                combineConversationName:String,
                forwardType:forwardMessageType) {
        super.init(frame: UIScreen.main.bounds)
        self.conversation = conversation
        self.conversationType = conversationType
        self.forwardType = forwardType
        self.combineConversationName = combineConversationName
        addSubviews()
        updateSubviewContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        backgroundColor = UIColor(hex: 0x000000, a: 0.4)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(conversationAvatar)
        containerView.addSubview(userNameLabel)
        containerView.addSubview(forwardTypeView)
        forwardTypeView.addSubview(forwardTypeLabel)
        containerView.addSubview(cancelButton)
        containerView.addSubview(sureButton)
        containerView.addSubview(dividerView)
        containerView.addSubview(centerLine)
        
        setupConstraints()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.addGestureRecognizer(tap)
        
        cancelButton.addTarget(self, action: #selector(cancelItemClick(_:)), for: .touchUpInside)
        sureButton.addTarget(self, action: #selector(sureItemClick(_:)), for: .touchUpInside)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.heightAnchor.pin(equalToConstant: (199.0) / 270.0 * (UIScreen.main.bounds.width - 106)),
            containerView.widthAnchor.pin(equalToConstant: UIScreen.main.bounds.width - 106),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.pin(equalToConstant: 22),
            
            
            conversationAvatar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            conversationAvatar.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 0),
            conversationAvatar.widthAnchor.pin(equalToConstant: 32),
            conversationAvatar.heightAnchor.pin(equalToConstant: 32),
            
            userNameLabel.centerYAnchor.constraint(equalTo: conversationAvatar.centerYAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: conversationAvatar.trailingAnchor, constant: 8),
            userNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            userNameLabel.heightAnchor.pin(equalToConstant: 21),
            
            forwardTypeView.topAnchor.constraint(equalTo: conversationAvatar.bottomAnchor, constant: 16),
            forwardTypeView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 0),
            forwardTypeView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            forwardTypeView.heightAnchor.pin(equalToConstant: 30),
            
            forwardTypeLabel.centerYAnchor.constraint(equalTo: forwardTypeView.centerYAnchor),
            forwardTypeLabel.leadingAnchor.constraint(equalTo: forwardTypeView.leadingAnchor, constant: 10),
            forwardTypeLabel.trailingAnchor.constraint(equalTo: forwardTypeView.trailingAnchor, constant: -10),
            forwardTypeLabel.heightAnchor.pin(equalToConstant: 18),
            
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            cancelButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5),
            cancelButton.heightAnchor.pin(equalToConstant: 50),
            
            sureButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            sureButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            sureButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5),
            sureButton.heightAnchor.pin(equalToConstant: 50),
            
            dividerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dividerView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            
            
            centerLine.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            centerLine.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            centerLine.widthAnchor.constraint(equalToConstant: 1),
            centerLine.heightAnchor.constraint(equalToConstant: 50),
            
        ])
        
    }
    
    func updateSubviewContent () {
        
        userNameLabel.text = conversation?.name
        let avatarUrl = conversation?.avatarUrl ?? ""
        var placeHolder = "avatar_default"
        if conversation?.type == .group {
            placeHolder = "groupAvatar_default"
        }
        
        if avatarUrl.count > 0 && avatarUrl.hasPrefix("http") {
            conversationAvatar.loadImage(with: avatarUrl, placeholder: placeHolder)
        } else {
            conversationAvatar.image = loadImageSafely(with: placeHolder)
        }
        
        if conversationType == .group {
            if forwardType == .mergeForward {
                forwardTypeLabel.text = L10n("merge_forward_group") + L10n("group_message")
            } else if forwardType == .itemByItemForward {
                forwardTypeLabel.text = L10n("merge_forward_peer") + L10n("group_message")
            } else {
                forwardTypeLabel.text = combineConversationName
            }
        } else {
            if forwardType == .mergeForward {
                forwardTypeLabel.text = L10n("merge_forward_group") + L10n("forward_message_peer",(ZIMKit.localUser?.name ?? ""),combineConversationName) + L10n("peer_message")
            } else if forwardType == .itemByItemForward {
                forwardTypeLabel.text = L10n("merge_forward_peer") +  L10n("forward_message_peer",(ZIMKit.localUser?.name ?? ""),combineConversationName) + L10n("peer_message")
            } else {
                forwardTypeLabel.text = combineConversationName
            }
        }
        
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
        
    }
    
    @objc func sureItemClick(_ button: UIButton) {
        self.hideView()
        delegate?.didClickSendCombineMessage(conversation:conversation!)
    }
}
