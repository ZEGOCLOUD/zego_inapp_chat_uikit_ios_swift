//
//  ConversationListVC.swift
//  ZIMKitConversation
//
//  Created by Kael Ding on 2022/7/29.
//

import UIKit
import ZIM
import ZegoPluginAdapter

let tableHeaderHeight = 40.0

open class ZIMKitMessagesListVC: _ViewController {
    
    lazy var viewModel = MessageListViewModel(conversationID: conversationID, conversationType)
    @objc public weak var delegate: ZIMKitMessagesListVCDelegate?
    
    @objc public var conversationID: String = ""
    @objc public var conversationName: String = ""
    @objc public var conversationType: ZIMConversationType = .peer
    //    @objc public var inputConfig: InputConfig?
    private var conversation: ZIMKitConversation?
    var firstHistoryMessageViewModel: MessageViewModel?
    
    /// Create a session page VC first, then you can create a session page by pushing or presenting the VC.
    /// - Parameters:
    ///   - conversationID: session ID.
    ///   - type: session type.
    ///   - conversationName: session name.
    @objc public convenience init(conversationID: String,
                                  type: ZIMConversationType,
                                  conversationName: String = "") {
        self.init()
        self.conversationID = conversationID
        self.conversationName = conversationName
        self.conversationType = type
        //        self.inputConfig = inputConfig
    }
    
    lazy var zoomTransitionController = ZoomTransitionController()
    
    lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: tableHeaderHeight))
        if #available(iOS 13.0, *) {
            indicatorView.style = .medium
        } else {
            indicatorView.style = .gray
        }
        return indicatorView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView().withoutAutoresizingMaskConstraints
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .zim_backgroundGray1
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = indicatorView
        
        tableView.register(TextMessageCell.self, forCellReuseIdentifier: TextMessageCell.reuseId)
        tableView.register(SystemMessageCell.self, forCellReuseIdentifier: SystemMessageCell.reuseId)
        tableView.register(ImageMessageCell.self, forCellReuseIdentifier: ImageMessageCell.reuseId)
        tableView.register(AudioMessageCell.self, forCellReuseIdentifier: AudioMessageCell.reuseId)
        tableView.register(VideoMessageCell.self, forCellReuseIdentifier: VideoMessageCell.reuseId)
        tableView.register(FileMessageCell.self, forCellReuseIdentifier: FileMessageCell.reuseId)
        tableView.register(UnknownMessageCell.self, forCellReuseIdentifier: UnknownMessageCell.reuseId)
        tableView.register(RevokeMessageCell.self, forCellReuseIdentifier: RevokeMessageCell.reuseId)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        tableView.addGestureRecognizer(tap)
        
        return tableView
    }()
    
    lazy var chatBar: ChatBar = {
        let chatBar = ChatBar(peerConversation: conversationType == .peer).withoutAutoresizingMaskConstraints
        chatBar.delegate = self
        return chatBar
    }()
    
    var optionsView: MessageOptionsView?
    var customerHeaderView: UIView?
    lazy var audioPlayer = MessageAudioPlayer(with: tableView)
    
    open override func setUp() {
        super.setUp()
        
        view.backgroundColor = .zim_backgroundGray5
    }
    
    open override func setUpLayout() {
        super.setUpLayout()
        
        view.addSubview(tableView)
        view.addSubview(chatBar)
        
        chatBar.pin(anchors: [.left, .right, .bottom], to: view)
        
        tableView.pin(anchors: [.left, .right, .top], to: view)
        tableView.bottomAnchor.pin(equalTo: chatBar.topAnchor).isActive = true
        
    }
    
    open override func updateContent() {
        super.updateContent()
    }
    
    //MARK: 设置导航栏相关
    func setupNav() {
        if let headerView = self.delegate?.getMessageListHeaderCustomerView?(self) {
            self.navigationItem.leftBarButtonItems = [setNavigationBackItem()]
            headerView.frame = CGRectMake(40, 0, UIScreen.main.bounds.width - 40, 44)
            customerHeaderView = headerView
            self.navigationController?.navigationBar.addSubview(customerHeaderView!)
            self.setNavigationBarTitle(title: "")
        } else if let header = self.delegate?.getMessageListHeaderBar?(self) {
            if let titleView = header.titleView {
                self.navigationItem.titleView = titleView
            }
            var leftNavigationItems: [UIBarButtonItem] = [setNavigationBackItem()]
            
            if let leftItems = header.leftItems {
                leftNavigationItems.append(contentsOf: leftItems)
            }
            self.navigationItem.leftBarButtonItems = leftNavigationItems
            
            if let rightItems = header.rightItems {
                self.navigationItem.rightBarButtonItems = rightItems
            }
        } else {
            addDefaultNavigationBar()
        }
    }
    
    func setNavigationBarTitle(title:String) {
        if self.customerHeaderView == nil {
            self.navigationItem.title = title
        } else {
            self.navigationItem.title = ""
        }
    }
    
    func setNavigationBackItem() ->UIBarButtonItem {
        let leftButton = UIButton(type: .custom)
        if viewModel.isShowCheckBox {
            leftButton.setTitle(L10n("conversation_cancel"), for: .normal)
            leftButton.setTitleColor(.zim_textBlack1, for: .normal)
        } else {
            leftButton.setImage(loadImageSafely(with: "chat_nav_left"), for: .normal)
        }
        leftButton.addTarget(self, action: #selector(leftItemClick), for: .touchUpInside)
        leftButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        if !viewModel.isShowCheckBox {
            leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        }
        let leftItem = UIBarButtonItem(customView: leftButton)
        return leftItem
    }
    
    func addDefaultNavigationBar() {
        if conversationName.count > 0 {
            self.setNavigationBarTitle(title: conversationName)
        } else {
            let name = conversationType == .peer ?
            L10n("message_title_chat") :
            L10n("message_title_group_chat")
            self.setNavigationBarTitle(title: name)
        }
        
        self.navigationItem.leftBarButtonItem = setNavigationBackItem()
        
        let rightButton = UIButton(type: .custom)
        rightButton.setImage(loadImageSafely(with: "chat_nav_right"), for: .normal)
        rightButton.addTarget(self, action: #selector(rightItemClick(_:)), for: .touchUpInside)
        rightButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let rightItem = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = viewModel.isShowCheckBox ? nil : rightItem
        
    }
    
    //MARK: lifeCycle
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        configViewModel()
        getMessageList()
        loadConversationInfo()
        addNotifications()
        setupNav()
        getCurrentConversionInfo()
        initCallConfig()
    }
    
    deinit {
        removeNotifications()
    }
    
    open override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            viewModel.clearConversationUnreadMessageCount()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioPlayer.stop()
        chatBar.resignFirstResponder()
    }
    
    func initCallConfig() {
        
        let appID = ZIMKit().imKitConfig.appID
        let appSign = ZIMKit().imKitConfig.appSign
        let userID = ZIMKit.localUser?.id ?? ""
        let userName = ZIMKit.localUser?.name ?? ""
        let callConfig = ZIMKit().imKitConfig.callPluginConfig
        if (appID ?? 0 <= 0) || appSign.count <= 0  || callConfig == nil {return}
        ZegoPluginAdapter.callPlugin?.initWith(appID: appID!, appSign: appSign, userID: userID, userName: userName, callPluginConfig: callConfig!)
        
    }
    
    // observe viewModel's properties
    func configViewModel() {
        viewModel.$isReceiveNewMessage.bind { [weak self] _ in
            self?.tableView.reloadData()
            self?.scrollToBottom(true)
            self?.hideOptionsView()
        }
        
        viewModel.$isRevokeMessageIndexPath.bind { [weak self] _ in
            
            if let validIndexPath = self?.viewModel.isRevokeMessageIndexPath {
                self?.tableView.reloadRows(at: [validIndexPath], with: UITableView.RowAnimation.none)
                self?.scrollToBottom(true)
                self?.hideOptionsView()
            }
        }
        
        viewModel.$isSendingNewMessage.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
        viewModel.$connectionEvent.bind { [weak self] event in
            if event == .kickedOut {
                self?.chatBar.cancelRecord()
                self?.hideOptionsView()
            }
        }
        viewModel.$isHistoryMessageLoaded.bind { [weak self] _ in
            guard let self  = self else { return }
            if self.viewModel.isNoMoreMsg {
                self.indicatorView.h = 0
            } else {
                self.indicatorView.h = tableHeaderHeight
            }
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            
            guard let lastMessageViewModel = self.firstHistoryMessageViewModel else { return }
            
            var visibleHeight = 0.0
            for msgViewModel in self.viewModel.messageViewModels {
                if msgViewModel === lastMessageViewModel { break }
                visibleHeight += msgViewModel.cellHeight
            }
            
            if self.viewModel.isNoMoreMsg {
                visibleHeight -= tableHeaderHeight
            }
            if !lastMessageViewModel.isShowTime {
                visibleHeight -= 32.5
            }
            let contentY = visibleHeight - self.tableView.safeAreaInsets.top - self.tableView.contentInset.top
            self.tableView.setContentOffset(CGPoint(x: 0, y: contentY), animated: false)
        }
    }
    
    func getMessageList() {
        viewModel.getMessageList { [weak self] error in
            guard let self  = self else { return }
            
            self.indicatorView.stopAnimating()
            if error.code != .ZIMErrorCodeSuccess {
                HUDHelper.showErrorMessageIfNeeded(error.code.rawValue,
                                                   defaultMessage: error.message)
                return
            }
            if self.viewModel.isNoMoreMsg {
                self.indicatorView.h = 0
            } else {
                self.indicatorView.h = tableHeaderHeight
            }
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            self.scrollToBottom(false)
        }
    }
    
    func loadMoreMessages() {
        
        if viewModel.isLoadingData { return }
        
        if viewModel.isNoMoreMsg {
            indicatorView.stopAnimating()
            return
        }
        
        firstHistoryMessageViewModel = viewModel.messageViewModels.first
        
        viewModel.loadMoreMessages { [weak self] error in
            self?.indicatorView.stopAnimating()
            if error.code != .ZIMErrorCodeSuccess {
                HUDHelper.showErrorMessageIfNeeded(error.code.rawValue,
                                                   defaultMessage: error.message)
                return
            }
        }
    }
    
    func loadConversationInfo() {
        if conversationType == .peer {
            viewModel.queryOtherUserInfo { [weak self] otherUser, error in
                if error.code == .ZIMErrorCodeSuccess {
                    self?.setNavigationBarTitle(title: otherUser?.name ?? "")
                    self?.conversationName = otherUser?.name ?? ""
                }
            }
        } else if conversationType == .group {
            performLogicAfterBothInterfacesSucceed()
        }
    }
    
    func queryGroupInfo(completion: @escaping (Bool,String) -> Void) {
        viewModel.queryGroupInfo { [weak self] info, error in
            if error.code == .ZIMErrorCodeSuccess {
                self?.setNavigationBarTitle(title: info?.name  ?? "")
                completion(true,info?.name ?? "")
            } else {
                completion(false,"")
            }
        }
    }
    
    func queryGroupMemberList(completion: @escaping (Bool,Int) -> Void) {
        ZIMKit.queryGroupMemberList(by: conversationID, maxCount: 100, nextFlag: 0) { memberList, nextFlag, error in
            if error.code.rawValue == 0 {
                completion(true,memberList.count)
            } else {
                print("[ERROR] queryGroupMemberList code = \(error.code)")
                completion(false,0)
            }
        }
    }
    
    func performLogicAfterBothInterfacesSucceed() {
        var interface1Succeeded = false
        var interface2Succeeded = false
        var groupName = ""
        var groupCount = 0
        queryGroupInfo { [self] succeeded,name in
            interface1Succeeded = succeeded
            groupName = name
            
            if interface1Succeeded && interface2Succeeded {
                if self.customerHeaderView == nil {
                    let title:String = name + "  " + "(\(groupCount))"
                    self.setNavigationBarTitle(title: title)
                }
                self.conversationName = name
            }
        }
        
        queryGroupMemberList { [self] succeeded,count in
            interface2Succeeded = succeeded
            groupCount = count
            if interface1Succeeded && interface2Succeeded {
                if self.customerHeaderView == nil {
                    let title:String = groupName + "  " + "(\(groupCount))"
                    self.setNavigationBarTitle(title: title)
                }
            }
        }
    }
    
    
    func getCurrentConversionInfo() {
        ZIMKit.queryConversation(for: conversationID, type: conversationType) { [weak self] conversation, error in
            if error.code.rawValue == 0 {
                self?.conversation = conversation
            } else {
                self?.conversation = ZIMKitConversation(with: ZIMConversation())
                self?.conversation?.id = self?.conversationID ?? ""
                self?.conversation?.name = self?.conversationName ?? ""
            }
        }
    }
}

// MARK: - Actions
extension ZIMKitMessagesListVC {
    @objc func leftItemClick(_ btn: UIButton) {
        if viewModel.isShowCheckBox {
            enableMultiSelect(false)
        } else {
            self.customerHeaderView?.removeFromSuperview()
            self.delegate?.messageListViewWillDisappear?()
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func rightItemClick(_ btn: UIButton) {
        if conversationType == .group {
            let groupDetailVC = GroupDetailVC(conversation: conversation!)
            groupDetailVC.delegate = self
            self.navigationController?.pushViewController(groupDetailVC, animated: true)
            
        } else {
            let singleChatDetailVC = ZIMKitSingleDetailChatVC(conversation: conversation!)
            singleChatDetailVC.delegate = self
            self.navigationController?.pushViewController(singleChatDetailVC, animated: true)
            
        }
    }
    
    @objc func tap(_ tap: UITapGestureRecognizer?) {
        chatBar.resignFirstResponder()
    }
}

// MARK: - TableView
extension ZIMKitMessagesListVC: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messageViewModels.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row >= viewModel.messageViewModels.count {
            return MessageCell()
        }
        
        let messageVM = viewModel.messageViewModels[indexPath.row]
        messageVM.isShowCheckBox = viewModel.isShowCheckBox
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: messageVM.reuseIdentifier, for: indexPath) as! MessageCell
        
        cell.messageVM = messageVM
        cell.delegate = self
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row >= viewModel.messageViewModels.count {
            return
        }
        let messageVM = viewModel.messageViewModels[indexPath.row]
        let message = messageVM.message
        
        guard let cell = cell as? MessageCell else { return }
        if message.info.senderUserName == nil {
            viewModel.queryMessageUserInfo(message.info.senderUserID) { [weak cell] error in
                cell?.updateSenderUserInfo()
            }
        }
    }
}

extension ZIMKitMessagesListVC: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= viewModel.messageViewModels.count {
            return 59.0
        }
        let messageVM = viewModel.messageViewModels[indexPath.row]
        return messageVM.message.type == .revoke ? 30 : messageVM.cellHeight
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        chatBar.resignFirstResponder()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let minContentY = tableHeaderHeight - tableView.safeAreaInsets.top - tableView.contentInset.top
        if scrollView.contentOffset.y < minContentY && !viewModel.isNoMoreMsg {
            if !indicatorView.isAnimating {
                indicatorView.startAnimating()
                self.loadMoreMessages()
            }
        } else {
            if indicatorView.isAnimating {
                indicatorView.stopAnimating()
            }
        }
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let minContentY = tableHeaderHeight - tableView.safeAreaInsets.top - tableView.contentInset.top
        if scrollView.contentOffset.y < minContentY && !viewModel.isNoMoreMsg {
            self.loadMoreMessages()
        }
    }
}

extension ZIMKitMessagesListVC: ChatBarDelegate {
    
    func chatBar(_ chatBar: ChatBar, didChangeStatus status: ChatBarStatus) {
        
    }
    
    func chatBarDidUpdateConstraints(_ chatBar: ChatBar) {
        if chatBar.status == .select ||
            chatBar.status == .normal ||
            chatBar.status == .voice { return }
        scrollToBottom(false)
    }
    
    func chatBar(_ chatBar: ChatBar, didSendText text: String) {
        hideOptionsView()
        if text.isEmpty {
            let message = L10n("message_cant_send_empty_msg")
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: L10n("common_sure"), style: .cancel)
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        
        if conversationType == .peer {
            ZIMKit.sendTextMessage(text, to: conversationID, type: conversationType) { [weak self] error in
                if error.code != .ZIMErrorCodeSuccess {
                    self?.showError(error)
                }
            }
        } else if conversationType == .group {
            ZIMKit.sendTextMessage(text, to: conversationID, type: conversationType,conversationName: conversationName) { [weak self] error in
                if error.code != .ZIMErrorCodeSuccess {
                    self?.showError(error)
                }
            }
        }
    }
    
    func chatBar(_ chatBar: ChatBar, didSendAudioWith path: String, duration: UInt32) {
        if conversationType == .peer {
            ZIMKit.sendAudioMessage(path, duration: duration, to: conversationID, type: conversationType) { [weak self] error in
                if error.code != .ZIMErrorCodeSuccess {
                    self?.showError(error)
                }
            }
        } else if conversationType == .group {
            ZIMKit.sendAudioMessage(path, duration: duration, to: conversationID, type: conversationType,conversationName: conversationName) { [weak self] error in
                if error.code != .ZIMErrorCodeSuccess {
                    self?.showError(error)
                }
            }
        }
    }
    
    func chatBar(_ chatBar: ChatBar, didSelectMoreViewWith type: ZIMKitMenuBarButtonName) {
        if type == .picture {
            selectPhotoForSend()
        } else if type == .file {
            selectFileForSend()
        } else if type == .takePhoto {
            takeCameraPhoto()
        } else if type == .voiceCall ||
                    type == .videoCall {
            
            let user: ZegoPluginCallUser = ZegoPluginCallUser(userID: self.conversation?.id ?? "", userName: self.conversation?.name ?? "", avatar: self.conversation?.avatarUrl ?? "")
            let customerData = zimKit_convertDictToString(dict: ["source": "zimkit"] as [String :AnyObject]) ?? ""
            ZegoPluginAdapter.callPlugin?.sendInvitationWithUIChange(invitees: [user], invitationType: type == .voiceCall ? .voiceCall : .videoCall, customData: customerData, timeout: 60, notificationConfig: ZegoSignalingPluginNotificationConfig(resourceID: ZIMKit().imKitConfig.callPluginConfig?.resourceID ?? "", title: "", message: ""), callback: { data in
                
            })
        }
    }
    
    func chatBar(_ chatBar: ChatBar, didStartToRecord recorder: AudioRecorder) {
        audioPlayer.stop()
    }
    
    func chatBarDidClickDeleteButton(_ chatBar: ChatBar) {
        let messages = viewModel.messageViewModels.filter({ $0.isSelected })
        if messages.count == 0 { return }
        // delete selected messages.
        deleteMessages(messages) { [weak self] delete in
            if delete {
                self?.enableMultiSelect(false)
            }
        }
    }
    func chatBarDidClickFullScreenEnterButton(content:String) {
        let fullEnterView = ZIMKitFullScreenEnterView(content: content, conversationName: self.conversationName)
        fullEnterView.delegate = self
        fullEnterView.showView()
    }
}

// MARK: - FullScreenViewDelegate
extension ZIMKitMessagesListVC: FullScreenEnterDelegate {
    func didClickExitFullScreenEnter(content: String) {
        chatBar.chatTextView.textView.becomeFirstResponder()
        chatBar.chatTextView.textView.text = content
    }
    
    func didClickSendMessage(content: String) {
        chatBar.chatTextView.textView.becomeFirstResponder()
        chatBar(chatBar, didSendText: content)
        chatBar.clearTextViewInput()
    }
    
}
// MARK: - MessageCellDelegate
extension ZIMKitMessagesListVC: ImageMessageCellDelegate,
                                UIViewControllerTransitioningDelegate,
                                AudioMessageCellDelegate,
                                VideoMessageCellDelegate,
                                FileMessageDelegate {
    func imageMessageCell(_ cell: ImageMessageCell, didClickImageWith messageVM: ImageMessageViewModel) {
        let galleryVC = GalleryVC()
        galleryVC.modalPresentationStyle = .overFullScreen
        galleryVC.transitioningDelegate = self
        
        let viewModels = viewModel.messageViewModels.filter { $0.message.type == .image }
        let index = viewModels.firstIndex(where: { $0.message === messageVM.message }) ?? 0
        
        galleryVC.content = .init(messageViewModels: viewModels,
                                  currentMessageVM: messageVM,
                                  index: index)
        
        galleryVC.transitionController = zoomTransitionController
        
        zoomTransitionController.presentedVCImageView = { [weak galleryVC] in
            let imageView =  galleryVC?.imageViewToAnimateWhenDismissing
            return imageView
        }
        
        zoomTransitionController.presentingImageView = { [weak self, weak galleryVC, weak cell] in
            guard let self = self else { return nil }
            guard let galleryVC = galleryVC else { return nil }
            guard let cell = cell else { return nil }
            
            guard let cells = self.tableView.visibleCells as? [MessageCell] else { return nil }
            for cell in cells where cell.messageVM === galleryVC.content.currentMessageVM  {
                guard let cell = cell as? ImageMessageCell else { return nil }
                return cell.thumbnailImageView
            }
            return cell.thumbnailImageView
        }
        zoomTransitionController.fromImageView = cell.thumbnailImageView
        present(galleryVC, animated: true)
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        zoomTransitionController.animationController(
            forPresented: presented,
            presenting: presenting,
            source: source)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        zoomTransitionController.animationController(forDismissed: dismissed)
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        zoomTransitionController.interactionControllerForDismissal(using: animator)
    }
    
    func audioMessageCell(_ cell: AudioMessageCell, didClickWith message: AudioMessageViewModel) {
        //        if FileManager.default.fileExists(atPath: message.fileLocalPath) {
        if FileManager.default.fileExists(atPath: message.message.audioContent.fileLocalPath) {
            if !audioPlayer.play(with: message) {
                // show play failed tips.
                HUDHelper.showMessage(L10n("message_audio_play_error_tips"))
            }
        } else {
            print("⚠️Audio File not exist: \(message.message.audioContent.fileLocalPath)")
        }
    }
    
    func videoMessageCell(_ cell: VideoMessageCell, didClickImageWith messageVM: VideoMessageViewModel) {
        audioPlayer.stop()
        let playerViewController = MessageAVPlayerViewController()
        playerViewController.setup(with: messageVM)
        present(playerViewController, animated: true) {
            playerViewController.play()
        }
    }
    
    func fileMessageCell(_ cell: FileMessageCell, didClickImageWith message: FileMessageViewModel) {
        previewFile(with: message, cell: cell)
    }
    
    func messageCell(_ cell: MessageCell, longPressWith message: MessageViewModel) {
        showOptionsView(cell, message)
    }
}

// MARK: - Send Messages
extension ZIMKitMessagesListVC {
    func sendImageMessage(with url: URL) {
        if conversationType == .peer {
            ZIMKit.sendImageMessage(url.path, to: conversationID, type: conversationType) { [weak self] error in
                if error.code != .ZIMErrorCodeSuccess {
                    self?.showError(error, .image)
                }
            }
        } else if conversationType == .group {
            ZIMKit.sendImageMessage(url.path, to: conversationID, type: conversationType,conversationName: conversationName) { [weak self] error in
                if error.code != .ZIMErrorCodeSuccess {
                    self?.showError(error, .image)
                }
            }
        }
    }
    
    func sendVideoMessage(with url: URL) {
        if conversationType == .peer {
            ZIMKit.sendVideoMessage(url.path, to: conversationID, type: conversationType) { [weak self] error in
                if error.code != .ZIMErrorCodeSuccess {
                    self?.showError(error, .video)
                }
            }
        } else if conversationType == .group {
            ZIMKit.sendVideoMessage(url.path, to: conversationID, type: conversationType, conversationName: conversationName) { [weak self] error in
                if error.code != .ZIMErrorCodeSuccess {
                    self?.showError(error, .video)
                }
            }
        }
    }
    
    func sendFileMessage(with url: URL) {
        if conversationType == .peer {
            ZIMKit.sendFileMessage(url.path, to: conversationID, type: conversationType) { [weak self] error in
                if error.code != .ZIMErrorCodeSuccess {
                    self?.showError(error, .file)
                }
            }
        } else if conversationType == .group {
            ZIMKit.sendFileMessage(url.path, to: conversationID, type: conversationType, conversationName: conversationName) { [weak self] error in
                if error.code != .ZIMErrorCodeSuccess {
                    self?.showError(error, .file)
                }
            }
        }
    }
}

// MARK: - Private
extension ZIMKitMessagesListVC {
    func scrollToBottom(_ animated: Bool) {
        let originHeight = tableView.bounds.height
        let contentHeight = tableView.contentSize.height + view.safeAreaInsets.top
        if contentHeight > originHeight {
            let offset: CGPoint = .init(x: 0, y: tableView.contentSize.height-tableView.frame.size.height)
            tableView.setContentOffset(offset, animated: animated)
        }
    }
    
    func showError(_ error: ZIMError, _ type: ZIMMessageType = .text) {
        if error.code == .ZIMErrorCodeNetworkModuleNetworkError {
            HUDHelper.showErrorMessageIfNeeded(
                error.code.rawValue,
                defaultMessage: L10n("message_network_anomaly"))
        } else if error.code == .ZIMErrorCodeMessageModuleFileSizeInvalid {
            if type == .image {
                HUDHelper.showErrorMessageIfNeeded(
                    error.code.rawValue,
                    defaultMessage: L10n("message_photo_size_err_tips"))
            } else if type == .video {
                HUDHelper.showErrorMessageIfNeeded(
                    error.code.rawValue,
                    defaultMessage: L10n("message_video_size_err_tips"))
            } else if type == .file {
                HUDHelper.showErrorMessageIfNeeded(
                    error.code.rawValue,
                    defaultMessage: L10n("message_file_size_err_tips"))
            }
        } else {
            HUDHelper.showErrorMessageIfNeeded(
                error.code.rawValue,
                defaultMessage: error.message)
        }
    }
}

extension ZIMKitMessagesListVC : messageConversationUpdateDelegate,groupConversationUpdateDelegate {
    func messagePinned(isPinned: Bool) {
        self.conversation?.isPinned = isPinned
    }
    
    func messageNotDisturb(isDisturb: Bool) {
        self.conversation?.notificationStatus = isDisturb ? .notify : .doNotDisturb
    }
    
    func groupMessagePinned(isPinned: Bool) {
        self.conversation?.isPinned = isPinned
    }
    
    func groupMessageNotDisturb(isDisturb: Bool) {
        self.conversation?.notificationStatus = isDisturb ? .notify : .doNotDisturb
    }
    
    func groupMemberList(memberCount: Int) {
        let title = conversationName + "  " + "(\(memberCount))"
        self.setNavigationBarTitle(title: title)
    }
}
