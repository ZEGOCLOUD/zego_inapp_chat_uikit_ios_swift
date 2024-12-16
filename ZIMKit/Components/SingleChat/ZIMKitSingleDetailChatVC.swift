//
//  ZIMKitSingleChatVC.swift
//  ZIMKit
//
//  Created by zego on 2024/7/15.
//

import UIKit

protocol messageConversationUpdateDelegate: AnyObject {
    func messagePinned(isPinned: Bool)
    func messageNotDisturb(isDisturb: Bool)
    
}

class ZIMKitSingleDetailChatVC: _ViewController {
    public convenience init(conversation: ZIMKitConversation,messageCount: Int) {
        self.init()
        self.messageCount = messageCount
        self.conversation = conversation
    }
    var messageCount:Int = 0
    var conversation: ZIMKitConversation!
    var delegate:messageConversationUpdateDelegate?
    //    var isNotDisturb:Bool = true
    
    lazy var userInfoView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundWhite
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var contentItemView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundWhite
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var userAvatarView: UIImageView = {
        let view = UIImageView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundWhite
        view.layer.cornerRadius = 9.8
        view.layer.masksToBounds = true
        view.loadImage(with: conversation.avatarUrl, placeholder: "avatar_default")
        return view
    }()
    
    lazy var userNameLB: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .zim_textBlack1
        label.text = conversation.name
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = .zim_backgroundWhite
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpSubviewsLayoutConstraint()
        updateSubviewsContent()
        loadConversationInfo()
        self.contentItemView.isHidden = (self.messageCount > 0) ? false : true
    }
    
    func loadConversationInfo() {
        ZIMKit.queryUserInfo(by: self.conversation.id) {[weak self] userInfo, error in
            guard let self = self else { return }
            if error.code == .ZIMErrorCodeSuccess {
                self.userAvatarView.loadImage(with: userInfo?.avatarUrl, placeholder: "avatar_default")
                self.userNameLB.text = userInfo?.name ?? ""
            }
        }
    }
    
    func setUpUI() {
        view.backgroundColor = .zim_backgroundGray5
        navigationItem.title = L10n("conversation_chat_setting")
        
        let leftButton = UIButton(type: .custom)
        leftButton.setImage(loadImageSafely(with: "chat_nav_left"), for: .normal)
        leftButton.addTarget(self, action: #selector(backItemClick(_:)), for: .touchUpInside)
        leftButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        let leftItem = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    func setUpSubviewsLayoutConstraint() {
        
        view.addSubview(userInfoView)
        NSLayoutConstraint.activate([
            userInfoView.topAnchor.pin(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            userInfoView.leadingAnchor.pin(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            userInfoView.trailingAnchor.pin(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            userInfoView.heightAnchor.pin(equalToConstant: 80.0)
        ])
        
        
        userInfoView.addSubview(userAvatarView)
        NSLayoutConstraint.activate([
            userAvatarView.leadingAnchor.pin(equalTo: userInfoView.leadingAnchor, constant: 16.0),
            userAvatarView.centerYAnchor.pin(equalTo: userInfoView.centerYAnchor),
            userAvatarView.heightAnchor.pin(equalToConstant: 48.0),
            userAvatarView.widthAnchor.pin(equalToConstant: 48.0)
        ])
        
        userInfoView.addSubview(userNameLB)
        NSLayoutConstraint.activate([
            userNameLB.leadingAnchor.pin(equalTo: userAvatarView.trailingAnchor, constant: 12.0),
            userNameLB.trailingAnchor.pin(equalTo: userInfoView.trailingAnchor, constant: -12.0),
            userNameLB.centerYAnchor.pin(equalTo: userInfoView.centerYAnchor),
            userNameLB.heightAnchor.pin(equalToConstant: 24.0)
        ])
        
        view.addSubview(contentItemView)
        NSLayoutConstraint.activate([
            contentItemView.topAnchor.pin(equalTo: userInfoView.bottomAnchor, constant: 16),
            contentItemView.leadingAnchor.pin(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            contentItemView.trailingAnchor.pin(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            contentItemView.heightAnchor.pin(equalToConstant: 108.0)
        ])
    }
    
    func updateSubviewsContent() {
        
        let itemArray:[String] = [L10n("conversation_chat_top"),L10n("conversation_chat_not_disturb")]
        for (index, title) in itemArray.enumerated() {
            let view: UIView = createItemView(title: title,indexTag: index + 1)
            contentItemView.addSubview(view)
            NSLayoutConstraint.activate([
                view.topAnchor.pin(equalTo: contentItemView.topAnchor, constant: CGFloat(index * 54)),
                view.widthAnchor.pin(equalTo: contentItemView.widthAnchor, constant: 20),
                view.heightAnchor.pin(equalToConstant: 54.0)
            ])
        }
    }
    
    func createItemView(title: String ,indexTag:Int)-> UIView {
        let view: UIView = UIView().withoutAutoresizingMaskConstraints
        
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .zim_textBlack1
        label.text = title
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.pin(equalTo: view.leadingAnchor, constant: 16),
            label.centerYAnchor.pin(equalTo: view.centerYAnchor),
            label.heightAnchor.pin(equalToConstant: 21.0)
        ])
        
        let switchButton: UISwitch = UISwitch().withoutAutoresizingMaskConstraints
        switchButton.addTarget(self, action: #selector(didItemClick(_:)), for: .touchUpInside)
        switchButton.onTintColor = .zim_backgroundBlue1
        switchButton.tag = indexTag
        if indexTag == 1 {
            switchButton.isOn = self.conversation.notificationStatus == .doNotDisturb ? true : false
        } else {
            switchButton.isOn = self.conversation.isPinned
        }
        view.addSubview(switchButton)
        NSLayoutConstraint.activate([
            switchButton.trailingAnchor.pin(equalTo: view.trailingAnchor, constant: -30),
            switchButton.centerYAnchor.pin(equalTo: view.centerYAnchor),
            switchButton.heightAnchor.pin(equalToConstant: 31.0),
            switchButton.widthAnchor.pin(equalToConstant: 51.0)
        ])
        return view
    }
    
    @objc func backItemClick(_ button: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didItemClick(_ button: UISwitch) {
        if button.tag == 1 {
            ZIMKit.setConversationNotificationStatus(for: self.conversation.id, type: .peer, status: button.isOn ? .doNotDisturb : .notify) { [weak self] error in
                print("设置免打扰 \(button.isOn ? "免打扰": "接收消息") error = \(error)")
                self?.delegate?.messageNotDisturb(isDisturb: button.isOn ? false : true)
            }
        } else {
            ZIMKit.updateConversationPinnedState(for: self.conversation.id, type: .peer, isPinned: button.isOn ? true : false) { [weak self] error in
                print("设置消息置顶 \(button.isOn ? "置顶": "取消置顶") error = \(error)")
                self?.delegate?.messagePinned(isPinned: button.isOn ? true : false)
            }
        }
    }
}
