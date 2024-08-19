//
//  GroupMemberListVC.swift
//  ZIMKit
//
//  Created by zego on 2024/7/25.
//

import UIKit

class GroupMemberListVC: UIViewController {
    
    public convenience init(conversationID: String , memberList:[ZIMKitGroupMemberInfo]) {
        self.init()
        self.conversationID = conversationID
        self.memberList = memberList.filter { $0.memberRole != .robot }
    }
    
    var memberList = [ZIMKitGroupMemberInfo]()
    
    var conversationID: String = ""
    lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain).withoutAutoresizingMaskConstraints
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .zim_backgroundGray5
        tableView.register(ZIMKitGroupMemberInfoTableViewCell.self, forCellReuseIdentifier: ZIMKitGroupMemberInfoTableViewCell.reuseId)
        return tableView
    }()
    
    lazy var contentViews: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundGray5
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryGroupMemberList()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zim_backgroundWhite
        setNavigationView()
        setUpLayout()
        tableView.reloadData()
    }
    
    func setNavigationView() {
        navigationItem.title = L10n("group_member_list")
        
        let leftButton = UIButton(type: .custom)
        leftButton.setImage(loadImageSafely(with: "chat_nav_left"), for: .normal)
        leftButton.addTarget(self, action: #selector(backItemClick(_:)), for: .touchUpInside)
        leftButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        let leftItem = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftItem
        
        
        let rightButton = UIButton(type: .custom)
        rightButton.setTitle(L10n("add_member_to_group"), for: .normal)
        rightButton.setTitleColor(.zim_backgroundBlue1, for: .normal)
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        rightButton.addTarget(self, action: #selector(addMemberToGroupClick(_:)), for: .touchUpInside)
        rightButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        rightButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let rightItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func setUpLayout() {
        
        view.addSubview(contentViews)
        NSLayoutConstraint.activate([
          contentViews.topAnchor.pin(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
          contentViews.leadingAnchor.pin(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
          contentViews.trailingAnchor.pin(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
          contentViews.bottomAnchor.pin(equalTo: view.bottomAnchor, constant: 0),
        ])
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func queryGroupMemberList() {
        ZIMKit.queryGroupMemberList(by: conversationID, maxCount: 100, nextFlag: 0) { [self] memberList, nextFlag, error in
            if error.code.rawValue == 0 {
                self.memberList = memberList
                tableView.reloadData()
            } else {
                print("[ERROR] queryGroupMemberList code = \(error.code)")
            }
        }
    }
    
    @objc func backItemClick(_ button: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func addMemberToGroupClick(_ button: UIButton) {
        let popView: ZIMKitInviteUserInGroupView = ZIMKitInviteUserInGroupView.init(conversationID: conversationID)
        popView.showView()
        popView.sureBlock = { [self] result in
            if result {
                queryGroupMemberList()
                tableView.reloadData()
            }
        }
    }
    
}

extension GroupMemberListVC :UITableViewDelegate,UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ZIMKitGroupMemberInfoTableViewCell.reuseId, for: indexPath) as! ZIMKitGroupMemberInfoTableViewCell
        let model:ZIMKitGroupMemberInfo = memberList[indexPath.row]
        cell.selectionStyle = .none
        
        cell.configure(with: model.userName, avatarUrl: model.userAvatarUrl)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}