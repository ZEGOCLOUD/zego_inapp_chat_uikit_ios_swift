//
//  ConversationListVC.swift
//  ZIMKitConversation
//
//  Created by Kael Ding on 2022/7/29.
//

import UIKit

protocol groupConversationUpdateDelegate: AnyObject {
    func groupMessagePinned(isPinned: Bool)
    func groupMessageNotDisturb(isDisturb: Bool)
    func groupMemberList(memberCount: Int)
    
}

class GroupDetailVC: _ViewController {
    public convenience init(conversation: ZIMKitConversation) {
        self.init()
        self.conversation = conversation
    }
    
    var conversation: ZIMKitConversation!
    let groupCount: Int = 10
    var memberList = [ZIMKitGroupMemberInfo]()
    
    lazy var groupMemberView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundWhite
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var memberTitleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.text = L10n("group_chat_member")
        label.textColor = .zim_textBlack1
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        return label
    }()
    
    lazy var tapView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundWhite
        view.isUserInteractionEnabled = true
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(intoMemberListClick(_:)))
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    lazy var memberListTipLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = UIColor(hex: 0x8E9093)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    lazy var nextImageView: UIImageView = {
        let imageView = UIImageView(image: loadImageSafely(with: "next_step_img")).withoutAutoresizingMaskConstraints
        return imageView
    }()
    
    lazy var groupConfigView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundWhite
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        return view
    }()
    
    private(set) lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 13
        layout.minimumInteritemSpacing = 8
        return layout
    }()
    
    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).withoutAutoresizingMaskConstraints
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = false
        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ZIMKitGroupMemberInfoCell.self, forCellWithReuseIdentifier: ZIMKitGroupMemberInfoCell.reuseId)
        return collectionView
    }()
    
    var delegate: groupConversationUpdateDelegate?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        queryGroupMemberList()
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .zim_backgroundGray5
        setNavigationView()
        
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        //        groupMemberView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = .zim_backgroundWhite
    }
    
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
    }
    
    func setNavigationView() {
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
    
    override func setUpLayout() {
        super.setUpLayout()
        
        view.addSubview(groupMemberView)
        NSLayoutConstraint.activate([
            groupMemberView.topAnchor.pin(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            groupMemberView.leadingAnchor.pin(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            groupMemberView.trailingAnchor.pin(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
            groupMemberView.heightAnchor.pin(equalToConstant: CGFloat(54 + 17))
        ])
        
        groupMemberView.addSubview(memberTitleLabel)
        NSLayoutConstraint.activate([
            memberTitleLabel.leadingAnchor.pin(equalTo: groupMemberView.leadingAnchor, constant: 16.0),
            memberTitleLabel.topAnchor.pin(equalTo: groupMemberView.topAnchor,constant: 16.0),
            memberTitleLabel.heightAnchor.pin(equalToConstant: 22.0)
        ])
        
        groupMemberView.addSubview(tapView)
        NSLayoutConstraint.activate([
            tapView.widthAnchor.pin(equalToConstant: 200.0),
            tapView.centerYAnchor.pin(equalTo: memberTitleLabel.centerYAnchor),
            tapView.heightAnchor.pin(equalToConstant: 24.0),
            tapView.trailingAnchor.pin(equalTo: groupMemberView.trailingAnchor, constant: -8.0)
        ])
        
        tapView.addSubview(nextImageView)
        NSLayoutConstraint.activate([
            nextImageView.trailingAnchor.pin(equalTo: tapView.trailingAnchor),
            nextImageView.centerYAnchor.pin(equalTo: tapView.centerYAnchor),
            nextImageView.heightAnchor.pin(equalToConstant: 24.0),
            nextImageView.widthAnchor.pin(equalToConstant: 24.0)
        ])
        
        tapView.addSubview(memberListTipLabel)
        NSLayoutConstraint.activate([
            memberListTipLabel.trailingAnchor.pin(equalTo: nextImageView.leadingAnchor, constant: -2.0),
            memberListTipLabel.centerYAnchor.pin(equalTo: tapView.centerYAnchor),
            memberListTipLabel.heightAnchor.pin(equalToConstant: 20.0)
        ])
        
        groupMemberView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.pin(equalTo: groupMemberView.topAnchor, constant: 54),
            collectionView.leadingAnchor.pin(equalTo: groupMemberView.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.pin(equalTo: groupMemberView.trailingAnchor, constant: -10.0),
            collectionView.bottomAnchor.pin(equalTo: groupMemberView.bottomAnchor, constant: -17),
        ])
        
        view.addSubview(groupConfigView)
        NSLayoutConstraint.activate([
            groupConfigView.topAnchor.pin(equalTo: groupMemberView.bottomAnchor, constant: 16),
            groupConfigView.leadingAnchor.pin(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            groupConfigView.trailingAnchor.pin(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
            groupConfigView.heightAnchor.pin(equalToConstant: 108.0)
        ])
    }
    
    override func updateContent() {
        
        let itemArray:[String] = [L10n("conversation_chat_top"),L10n("conversation_chat_not_disturb")]
        for (index, title) in itemArray.enumerated() {
            let view: UIView = createItemView(title: title,indexTag: index + 1)
            groupConfigView.addSubview(view)
            NSLayoutConstraint.activate([
                view.topAnchor.pin(equalTo: groupConfigView.topAnchor, constant: CGFloat(index * 54)),
                view.widthAnchor.pin(equalTo: groupConfigView.widthAnchor, constant: 20),
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
        
        
        if indexTag == 1 {
            let lineView: UIView = UIView().withoutAutoresizingMaskConstraints
            lineView.backgroundColor = UIColor(hex: 0xE6E6E6)
            view.addSubview(lineView)
            
            NSLayoutConstraint.activate([
                lineView.heightAnchor.constraint(equalToConstant: 0.5),
                lineView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -2),
                lineView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
                lineView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: 0)
            ])
        }
        return view
    }
    
    
    func queryGroupMemberList() {
        ZIMKit.queryGroupMemberList(by: conversation.id, maxCount: 100, nextFlag: 0) { [weak self] memberList, nextFlag, error in
            if error.code.rawValue == 0 {
                self?.memberList = memberList
                self?.updateUI()
            } else {
                print("[ERROR] queryGroupMemberList code = \(error.code)")
            }
        }
    }
    
    func calculateCollectionViewLines() -> Int {
        var rows = self.memberList.count / 5
        if self.memberList.count % 5 > 0 {
            rows += 1
        }
        if self.memberList.count == 5 {
            rows = 2
        }
        return rows >= 2 ? 2 : rows
    }
    
    func updateUI() {
        self.memberListTipLabel.text = L10n("look_member", self.memberList.count)
        let heightConstraint = groupMemberView.heightAnchor.constraint(equalToConstant: CGFloat(54 + 17 + calculateCollectionViewLines() * 58 + (calculateCollectionViewLines() - 1) * 13))
        heightConstraint.isActive = true
        groupMemberView.layoutIfNeeded()
        addInviteMemberJoinGroupButton()
        collectionView.reloadData()
        delegate?.groupMemberList(memberCount: self.memberList.count - 1 )
        
    }
    
    @objc func didItemClick(_ button: UISwitch) {
        if button.tag == 1 {
            ZIMKit.setConversationNotificationStatus(for: self.conversation.id, type: .group, status: button.isOn ? .doNotDisturb : .notify) { [weak self] error in
                if error.code.rawValue != 0 {
                    print("[ERROR] 设置群组免打扰 \(button.isOn ? "免打扰": "接收消息") errorCode = \(error.code)")
                } else {
                    self?.delegate?.groupMessageNotDisturb(isDisturb: button.isOn ? false : true)
                }
            }
        } else {
            ZIMKit.updateConversationPinnedState(for: self.conversation.id, type: .group, isPinned: button.isOn ? true : false) { [weak self] error in
                if error.code.rawValue != 0 {
                    print("[ERROR] 设置群组消息置顶 \(button.isOn ? "置顶": "取消置顶") errorCode = \(error.code)")
                } else {
                    self?.delegate?.groupMessagePinned(isPinned: button.isOn ? true : false)
                }
            }
        }
    }
    
    @objc func backItemClick(_ button: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func intoMemberListClick(_ tapGesture: UITapGestureRecognizer) {
        let vc:GroupMemberListVC = GroupMemberListVC(conversationID: conversation.id, memberList: memberList)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func addInviteMemberJoinGroupButton() {
        let inviteMemberInfo: ZIMKitGroupMemberInfo = ZIMKitGroupMemberInfo()
        inviteMemberInfo.userAvatarUrl = "icon_member_add"
        inviteMemberInfo.userName = L10n("invite_member_join_group")
        inviteMemberInfo.memberRole = .robot
        
        if self.memberList.count < 10 {
            self.memberList.append(inviteMemberInfo)
        } else {
            self.memberList.insert(inviteMemberInfo, at: 9)
        }
    }
    
    func inviteUserInToGroup() {
        let popView: ZIMKitInviteUserInGroupView = ZIMKitInviteUserInGroupView.init(conversationID: conversation.id)
        popView.showView()
        
        popView.sureBlock = { [weak self] result in
            if result {
                self?.queryGroupMemberList()
            }
        }
    }
}

extension GroupDetailVC :UICollectionViewDataSource,
                         UICollectionViewDelegate,
                         UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        memberList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZIMKitGroupMemberInfoCell.reuseId, for: indexPath) as? ZIMKitGroupMemberInfoCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.row >= memberList.count { return cell }
        
        let model:ZIMKitGroupMemberInfo = memberList[indexPath.row]
        
        if model.memberRole == .robot {
            cell.imageView.image = loadImageSafely(with: model.userAvatarUrl)
        } else {
            cell.imageView.loadImage(with: model.userAvatarUrl, placeholder: "avatar_default")
        }
        cell.memberName.text = model.userName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (view.frame.size.width - 20 - (16 * 4)) / 5
        return CGSize(width: itemWidth, height: 58)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let model:ZIMKitGroupMemberInfo = memberList[indexPath.row]
        if model.memberRole == .robot {
            self.inviteUserInToGroup()
        }
    }
}
