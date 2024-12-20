//
//  GroupChatRecordsVC.swift
//  Kingfisher
//
//  Created by zego on 2024/8/26.
//

import UIKit
import QuickLook
import ZIM
class GroupChatRecordsVC: UIViewController {
    
    var messageViewModels = [MessageViewModel]()
    lazy var audioPlayer = MessageAudioPlayer(with: tableView)
    var combineMessage:ZIMKitMessage?
    private var _currentFileMessageVM: FileMessageViewModel?
    private var _currentFileCell: FileMessageCell?
    lazy var zoomTransitionController = ZoomTransitionController()
    var navigationTitle: String = L10n("group_message")
    lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain).withoutAutoresizingMaskConstraints
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .zim_backgroundGray1
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(TextMessageCell.self, forCellReuseIdentifier: TextMessageCell.reuseId)
        tableView.register(CustomerMessageCell.self, forCellReuseIdentifier: CustomerMessageCell.reuseId)
        tableView.register(ImageMessageCell.self, forCellReuseIdentifier: ImageMessageCell.reuseId)
        tableView.register(AudioMessageCell.self, forCellReuseIdentifier: AudioMessageCell.reuseId)
        tableView.register(VideoMessageCell.self, forCellReuseIdentifier: VideoMessageCell.reuseId)
        tableView.register(FileMessageCell.self, forCellReuseIdentifier: FileMessageCell.reuseId)
        tableView.register(UnknownMessageCell.self, forCellReuseIdentifier: UnknownMessageCell.reuseId)
        tableView.register(RevokeMessageCell.self, forCellReuseIdentifier: RevokeMessageCell.reuseId)
        tableView.register(CombineMessageCell.self, forCellReuseIdentifier: CombineMessageCell.reuseId)
        tableView.register(TipsMessageCell.self, forCellReuseIdentifier: TipsMessageCell.reuseId)
        tableView.register(ReplyMessageCell.self, forCellReuseIdentifier: ReplyMessageCell.reuseId)
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor.white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        ZIMKit.registerZIMKitDelegate(self)
        setNavigationView()
        setUpLayout()
        getConversationList()
    }
    
    func setNavigationView() {
        
        navigationItem.title = navigationTitle
        
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
        ZIMKit.queryCombineMessageDetailByMessage(for: self.combineMessage!) { [weak self] conversations, error in
            if conversations.count <= 0 {return}
            self?.handleLoadedHistoryMessages(conversations)
        }
    }
    
    private func handleLoadedHistoryMessages(_ messages: [ZIMKitMessage]) {
        var newMessages: [MessageViewModel] = []
        for message in messages {
            message.info.direction = .receive
            let viewModel = MessageViewModelFactory.createMessage(with: message)
            viewModel.setNeedShowTime(newMessages.last?.message.info.timestamp)
            viewModel.setCellHeight()
            viewModel.message.info.direction = .receive
            newMessages.append(viewModel)
            autoDownloadFiles(with: viewModel)
        }
        if let lastMessageVM = messageViewModels.first {
            lastMessageVM.setNeedShowTime(newMessages.last?.message.info.timestamp)
            lastMessageVM.setCellHeight()
        }
        messageViewModels = newMessages + messageViewModels
        self.tableView.reloadData()
    }
    
    
    
    private func autoDownloadFiles(with viewModel: MessageViewModel) {
        let message = viewModel.message
        if message.type != .audio && message.type != .file { return }
        if FileManager.default.fileExists(atPath: message.fileLocalPath) { return }
        if message.fileSize > 1024 * 1024 * 10 { return }
        if message.fileDownloadUrl.count == 0 { return }
        
        guard let viewModel = viewModel as? MediaMessageViewModel else { return }
        downloadMediaMessage(viewModel) {error in
            if error.code != .ZIMErrorCodeSuccess {
                // #warning("The simple retry logic, will remove in future.")
                /// redownload after 5s, if failed.
                DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
                    self.autoDownloadFiles(with: viewModel)
                }
            }
        }
    }
    
    func downloadMediaMessage(_ viewModel: MediaMessageViewModel, callback: ((ZIMError) -> Void)? = nil) {
        if viewModel.isDownloading { return }
        viewModel.isDownloading = true
        let message = viewModel.message
        ZIMKit.downloadMediaFile(with: message,true) { error in
            viewModel.isDownloading = false
            if error.code == .ZIMErrorCodeSuccess {
                // print("✅Download File Success: \(message.fileName), localID: \(message.info.localMessageID)")
            } else {
                print("❌Download File Failed: \(message.fileName), localID: \(message.info.localMessageID)")
            }
            callback?(error )
        }
    }
    
    @objc func backItemClick(_ button: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func previewFile(with messageVM: FileMessageViewModel, cell: FileMessageCell) {
        _currentFileMessageVM = messageVM
        _currentFileCell = cell
        if FileManager.default.fileExists(atPath: messageVM.message.fileLocalPath) {
            let qlViewController = QLPreviewController()
            qlViewController.dataSource = self
            qlViewController.delegate = self
            present(qlViewController, animated: true)
            //            self.navigationController?.pushViewController(qlViewController, animated: true)
        } else {
            downloadMediaMessage(messageVM)
        }
    }
    
    
    func queryMessageUserInfo(_ userID: String, callback: ((ZIMError) -> ())? = nil) {
        ZIMKit.queryUserInfo(by: userID) { [weak self] user, error in
            self?.updateMessageUserInfo(with: userID,
                                        name: user?.name,
                                        avatarUrl: user?.avatarUrl)
            callback?(error)
        }
        
    }
    
    private func updateMessageUserInfo(with userID: String,
                                       name: String?,
                                       avatarUrl: String?) {
        for vm in messageViewModels {
            let msg = vm.message
            if userID != msg.info.senderUserID { continue }
            msg.info.senderUserName = name
            msg.info.senderUserAvatarUrl = avatarUrl
        }
    }
    
}

extension GroupChatRecordsVC: QLPreviewControllerDataSource,
                              QLPreviewControllerDelegate {
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        FilePreviewItem(with: _currentFileMessageVM!)
    }
    
    public func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        _currentFileCell?.containerView
    }
}

extension GroupChatRecordsVC :UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= messageViewModels.count {
            return MessageCell()
        }
        
        let messageVM = messageViewModels[indexPath.row]
        messageVM.isShowCheckBox = false
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: messageVM.reuseIdentifier, for: indexPath) as! MessageCell
        
        cell.messageVM = messageVM
        cell.delegate = self
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row >= messageViewModels.count {
            return
        }
        let messageVM = messageViewModels[indexPath.row]
        let message = messageVM.message
        
        guard let cell = cell as? MessageCell else { return }
        if message.info.senderUserName == nil {
            self.queryMessageUserInfo(message.info.senderUserID) { [weak cell] error in
                cell?.updateSenderUserInfo()
            }
        }
    }
    
}

extension GroupChatRecordsVC: UITableViewDelegate {
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= messageViewModels.count {
            return 59.0
        }
        let conversationModel = messageViewModels[indexPath.row]
        return conversationModel.message.type == .revoke ? 30 : conversationModel.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
extension GroupChatRecordsVC: AudioMessageCellDelegate,
                              VideoMessageCellDelegate,
                              FileMessageDelegate,
                              ImageMessageCellDelegate,
                              CombineMessageCellDelegate,
                              UIViewControllerTransitioningDelegate {
    func onClickSelectedCurrentMessage(_ messageViewModel: MessageViewModel, selected: Bool) {
        
    }
    
    func onClickEmojiReaction(_ cell: MessageCell, emoji: String) {
        
    }
    
    func audioMessageCell(_ cell: AudioMessageCell, didClickWith message: AudioMessageViewModel) {
        if FileManager.default.fileExists(atPath: message.message.audioContent.fileLocalPath) {
            if !audioPlayer.play(with: message) {
                // show play failed tips.
                HUDHelper.showMessage(L10n("message_audio_play_error_tips"))
            }
        } else {
            print("⚠️Audio File not exist: \(message.message.audioContent.fileLocalPath)")
        }
    }
    
    func videoMessageCell(_ cell: VideoMessageCell, didClickImageWith message: VideoMessageViewModel) {
        audioPlayer.stop()
        let playerViewController = MessageAVPlayerViewController()
        playerViewController.setup(with: message)
        present(playerViewController, animated: true) {
            playerViewController.play()
        }
    }
    
    func fileMessageCell(_ cell: FileMessageCell, didClickImageWith message: FileMessageViewModel) {
        previewFile(with: message, cell: cell)
    }
    
    func messageCell(_ cell: MessageCell, longPressWith messageViewModel: MessageViewModel) {
        
    }
    
    func imageMessageCell(_ cell: ImageMessageCell, didClickImageWith messageVM: ImageMessageViewModel) {
        let galleryVC = GalleryVC()
        galleryVC.modalPresentationStyle = .overFullScreen
        galleryVC.transitioningDelegate = self
        
        let viewModels = messageViewModels.filter { $0.message.type == .image }
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
            guard let self = self else { return UIImageView() }
            guard let galleryVC = galleryVC else { return UIImageView() }
            guard let cell = cell else { return UIImageView() }
            
            guard let cells = self.tableView.visibleCells as? [MessageCell] else { return UIImageView() }
            for cell in cells where cell.messageVM === galleryVC.content.currentMessageVM  {
                guard let cell = cell as? ImageMessageCell else { return UIImageView() }
                return cell.imageMediaView.thumbnailImageView
            }
            return cell.imageMediaView.thumbnailImageView
        }
        zoomTransitionController.fromImageView = cell.imageMediaView.thumbnailImageView
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
    
    //MARK: CombineMessageCellDelegate
    func combineMessageCell(_ cell: CombineMessageCell, didClickWith message: CombineMessageViewModel) {
        let groupDetailVC = GroupChatRecordsVC()
        groupDetailVC.navigationTitle = message.combineTitle
        groupDetailVC.combineMessage = message.message
        self.navigationController?.pushViewController(groupDetailVC, animated: true)
    }
    
}
extension GroupChatRecordsVC :ZIMKitDelegate {
    func onMediaMessageDownloadCompleteUpdated(_ message: ZIMKitMessage, isFinished: Bool) {
        if isFinished {
            for (index,model) in messageViewModels.enumerated() {
                if model.message.info.cbInnerID == message.zim?.cbInnerID {
                    messageViewModels[index].message = message
                }
            }
            
        }
    }
}
