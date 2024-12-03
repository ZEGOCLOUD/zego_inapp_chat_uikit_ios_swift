//
//  ZIMKitRecentChatListVC.swift
//  Kingfisher
//
//  Created by zego on 2024/8/22.
//

import UIKit
import ZIM

let combineContentMaxByte: Int = 500

enum forwardMessageType {
    case forward
    case mergeForward
    case itemByItemForward
}

protocol ZIMKitRecentChatListVCDelegate: AnyObject {
    func forwardMessageComplete()
}

class ZIMKitRecentChatListVC: UIViewController {
    
    
    var memberList = [ZIMKitConversation]()
    var conversationList = [ZIMKitMessage]()
    var forwardType: forwardMessageType = .forward
    var combineConversationName: String = ""
    var conversationType: ZIMConversationType = .peer
    lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain).withoutAutoresizingMaskConstraints
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .zim_backgroundGray5
        tableView.register(ZIMKitRecentChatListCell.self, forCellReuseIdentifier: ZIMKitRecentChatListCell.reuseId)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    public weak var delegate: ZIMKitRecentChatListVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor.white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        setNavigationView()
        setUpLayout()
        getConversationList()
    }
    
    func setNavigationView() {
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor.white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        navigationItem.title = L10n("chat_list")
        
        let leftButton = UIButton(type: .custom)
        leftButton.setImage(loadImageSafely(with: "chat_nav_left"), for: .normal)
        leftButton.addTarget(self, action: #selector(backItemClick(_:)), for: .touchUpInside)
        leftButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        let leftItem = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftItem
        
    }
    
    func setUpLayout() {
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func getConversationList() {
        ZIMKit.getConversationList {[weak self] conversations, error in
            self?.memberList = conversations
            self?.tableView.reloadData()
        }
    }
    
    @objc func backItemClick(_ button: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Customer
    func replaceConsecutiveEmojis(in string: String) -> String {
        let emojiPattern = "\\p{Emoji}{2,}"
        let regex = try! NSRegularExpression(pattern: emojiPattern, options: [])
        let range = NSRange(location: 0, length: string.utf16.count)
        return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "[表情]")
    }
}

extension ZIMKitRecentChatListVC :UITableViewDelegate,UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ZIMKitRecentChatListCell.reuseId, for: indexPath) as! ZIMKitRecentChatListCell
        let model:ZIMKitConversation = memberList[indexPath.row]
        cell.selectionStyle = .none
        
        cell.configure(with: model.name, avatarUrl: model.avatarUrl, groupConversation: model.type == .group)
        cell.lineView.isHidden = indexPath.row == (self.memberList.count - 1)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let view = ZIMKitMultipleForwardConfirmView(conversation: memberList[indexPath.row],conversationType: conversationType,combineConversationName: self.combineConversationName,forwardType: forwardType)
        view.showView()
        view.delegate = self
    }
}

extension ZIMKitRecentChatListVC:ForwardConversationDelegate {
    func didClickSendCombineMessage(conversation: ZIMKitConversation) {
        if forwardType == .mergeForward {
            HUDHelper.showLoading()
            var content = ""
            for (index,message) in conversationList.enumerated() {
                let originString = message.getShortString()
                let trimmedString = originString.trimmingCharacters(in:.whitespacesAndNewlines)
                let finalString = trimmedString.replacingOccurrences(of: "\n", with: "")
                var message:String = (message.info.senderUserName ?? "") + ": " + finalString
                if index != (conversationList.count - 1) {
                    message = message + "\n"
                }
//                message = replaceConsecutiveEmojis(in: message)
                let contentLength = content.data(using:.utf8)
                if let data = message.data(using:.utf8) {
                    let length = combineContentMaxByte - ((contentLength?.count ?? 0) + data.count)
                    if length < 0 {
                        let max = combineContentMaxByte - (contentLength?.count ?? 0) - 3
                        
                        let truncatedString = substringByByteCount2(message, byteCount: max)
                        message = truncatedString + "..."
                    }
                }
                if content.utf8.count + message.utf8.count > combineContentMaxByte {
                    break
                }
                content = content.appending(message)
            }
            var title:String = ""
            if conversationType == .group {
                title =  combineConversationName
            } else {
                title = L10n("forward_message_peer",(ZIMKit.localUser?.name ?? ""),combineConversationName) + L10n("peer_message")
            }
            
            ZIMKit.sendCombineMessage(conversationID: conversation.id, type: conversation.type , content: content, conversationName: conversation.name, combineTitle:title, messageList: conversationList) { [weak self] error in
                print("sendCombineMessage errorCode: \(error.code)")
                HUDHelper.dismiss()
                self?.delegate?.forwardMessageComplete()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    if error.code == .ZIMErrorCodeSuccess {
                        HUDHelper.showMessage(L10n("combine_success"))
                    } else {
                        HUDHelper.showMessage(L10n("combine_failed"))
                    }
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            HUDHelper.showLoading()
            ZIMKit.sendMessageOneByOne(conversationList, targetConversation: conversation) {
                HUDHelper.dismiss()
                self.popToPreviousViewController()
            }
            delegate?.forwardMessageComplete()
        }
        
    }
    
    private func popToPreviousViewController() {
        let workItem = DispatchWorkItem {
            HUDHelper.showMessage(L10n("combine_success"))
            self.navigationController?.popViewController(animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: workItem)
    }
    
    private func substringByByteCount2(_ str: String, byteCount: Int) -> String {
        var currentByteCount = 0
        var index = str.startIndex
        for scalar in str.unicodeScalars {
            let scalarByteCount: Int
            if scalar.value <= 0x7F {
                scalarByteCount = 1
            } else if scalar.value <= 0x7FF {
                scalarByteCount = 2
            } else if scalar.value <= 0xFFFF {
                scalarByteCount = 3
            } else {
                scalarByteCount = 4
            }
            if currentByteCount + scalarByteCount > byteCount {
                break
            }
            currentByteCount += scalarByteCount
            index = str.index(after: index)
        }
        return String(str[..<index])
    }
}
