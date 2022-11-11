//
//  ConversationListVC.swift
//  ZIMKitConversation
//
//  Created by Kael Ding on 2022/7/29.
//

import UIKit
import ZIM

public enum ConversationType {
    case peer
    case group
}

let tableHeaderHeight = 40.0

open class MessagesListVC: _ViewController {

    lazy var viewModel: MessagesViewModel = MessagesViewModel(conversationID: conversationID, conversationType)

    var conversationID: String = ""
    var conversationName: String = ""
    var conversationType: ConversationType = .peer

    /// Create a session page VC first, then you can create a session page by pushing or presenting the VC.
    /// - Parameters:
    ///   - conversationID: session ID.
    ///   - type: session type.
    ///   - conversationName: session name.
    public convenience init(conversationID: String,
                            type: ConversationType,
                            conversationName: String = "") {
        self.init()
        self.conversationID = conversationID
        self.conversationName = conversationName
        self.conversationType = type
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

        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        tableView.addGestureRecognizer(tap)

        return tableView
    }()

    lazy var chatBar: ChatBar = {
        let chatBar = ChatBar().withoutAutoresizingMaskConstraints
        chatBar.delegate = self
        return chatBar
    }()

    lazy var optionsView: MessageOptionsView = {
        let optionsView = MessageOptionsView(frame: view.bounds)
            .withoutAutoresizingMaskConstraints
        optionsView.delegate = self
        return optionsView
    }()

    lazy var audioPlayer = MessageAudioPlayer(with: tableView)

    open override func setUp() {
        super.setUp()

        view.backgroundColor = .zim_backgroundGray1
        setupNav()
    }

    open override func setUpLayout() {
        super.setUpLayout()

        // we need add tableView first,
        // or the navigationbar will change to translucent on ios 15.
        view.addSubview(tableView)
        view.addSubview(chatBar)

        chatBar.pin(anchors: [.left, .right, .bottom], to: view)

        tableView.pin(anchors: [.left, .right, .top], to: view)
        tableView.bottomAnchor.pin(equalTo: chatBar.topAnchor).isActive = true
    }

    open override func updateContent() {
        super.updateContent()

    }

    func setupNav() {
        if conversationName.count > 0 {
            navigationItem.title = conversationName
        } else {
            let name = conversationType == .peer ?
                L10n("message_title_chat") :
                L10n("message_title_group_chat")
            navigationItem.title = name
        }

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
        self.navigationItem.leftBarButtonItem = leftItem

        if conversationType == .group {
            let rightButton = UIButton(type: .custom)
            rightButton.setImage(loadImageSafely(with: "chat_nav_right"), for: .normal)
            rightButton.addTarget(self, action: #selector(rightItemClick(_:)), for: .touchUpInside)
            rightButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
            rightButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            let rightItem = UIBarButtonItem(customView: rightButton)
            navigationItem.rightBarButtonItem = viewModel.isShowCheckBox ? nil : rightItem
        }
    }

    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        configViewModel()
        loadData()
        loadGroupMember()
        loadConversationInfo()
        addNotifications()
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

    // observe viewmodel's properties
    func configViewModel() {
        //        viewModel.$messages.bind { [weak self] _ in
        //            self?.tableView.reloadData()
        //        }
        viewModel.$isReceiveNewMessage.bind { [weak self] _ in
            self?.tableView.reloadData()
            self?.scrollToBottom(true)
            self?.hideOptionsView()
        }
        viewModel.$isSendingNewMessage.bind { [weak self] _ in
            self?.tableView.reloadData()
            self?.scrollToBottom(true)
        }
        viewModel.$connectionEvent.bind { [weak self] event in
            if event == .kickedOut {
                self?.chatBar.cancelRecord()
                self?.hideOptionsView()
            }
        }
    }

    func loadData() {

        if viewModel.isLoadingData { return }

        if viewModel.isNoMoreMsg {
            indicatorView.stopAnimating()
            return
        }

        let lastMessage = viewModel.messages.first
        viewModel.queryHistoryMessage(by: conversationType) { [weak self] isFirstLoad, isNoMoreMsg, newMsgs, error in

            self?.indicatorView.stopAnimating()

            if error.code != .success {
                HUDHelper.showMessage(error.message)
                return
            }

            if isNoMoreMsg {
                self?.indicatorView.h = 0
            } else {
                self?.indicatorView.h = tableHeaderHeight
            }

            self?.tableView.reloadData()
            self?.tableView.layoutIfNeeded()

            if isFirstLoad {
                self?.scrollToBottom(false)
            } else {
                guard let lastMessage = lastMessage else { return }
                guard let tableView = self?.tableView else { return }

                var visibleHeight = 0.0
                newMsgs.forEach({ visibleHeight += $0.cellHeight })

                if isNoMoreMsg {
                    visibleHeight -= tableHeaderHeight
                }
                if !lastMessage.isShowTime {
                    visibleHeight -= 32.5
                }
                let contentY = visibleHeight - tableView.safeAreaInsets.top - tableView.contentInset.top
                tableView.setContentOffset(CGPoint(x: 0, y: contentY), animated: false)
            }
        }
    }

    func loadGroupMember() {
        if conversationType != .group { return }
        viewModel.queryGroupMemberList { [weak self] error in
            if self?.viewModel.groupMemberNextFlag != 0 {
                self?.loadGroupMember()
            } else {
                self?.tableView.reloadData()
            }
            if error.code != .success {
                HUDHelper.showMessage(String("\(error.code.rawValue)-\(error.message)"))
            }
        }
    }

    func loadConversationInfo() {
        if conversationType == .peer {
            viewModel.queryOtherUserInfo { [weak self] error in
                if error.code == .success {
                    self?.navigationItem.title = self?.viewModel.otherUser?.baseInfo.userName
                    self?.tableView.reloadData()
                }
            }
        } else if conversationType == .group {
            viewModel.queryGroupInfo { [weak self] info, error in
                if error.code == .success {
                    self?.navigationItem.title = info?.baseInfo.groupName
                }
            }
        }
    }
}

// MARK: - Actions
extension MessagesListVC {
    @objc func leftItemClick(_ btn: UIButton) {
        if viewModel.isShowCheckBox {
            enableMultiSelect(false)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc func rightItemClick(_ btn: UIButton) {
        Dispatcher.open(GroupDispatcher.groupDetail(conversationID, groupName: conversationName))
    }

    @objc func tap(_ tap: UITapGestureRecognizer?) {
        chatBar.resignFirstResponder()
    }
}

// MARK: - TableView
extension MessagesListVC: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row >= viewModel.messages.count {
            return MessageCell()
        }

        let message = viewModel.messages[indexPath.row]
        message.isShowCheckBox = viewModel.isShowCheckBox

        let cell = self.tableView.dequeueReusableCell(withIdentifier: message.reuseIdentifier, for: indexPath) as! MessageCell

        cell.message = message
        cell.delegate = self

        return cell
    }
}

extension MessagesListVC: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= viewModel.messages.count {
            return 59.0
        }
        let message = viewModel.messages[indexPath.row]
        return message.cellHeight
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        chatBar.resignFirstResponder()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let minContentY = tableHeaderHeight - tableView.safeAreaInsets.top - tableView.contentInset.top
        if scrollView.contentOffset.y < minContentY && !viewModel.isNoMoreMsg {
            if !indicatorView.isAnimating {
                indicatorView.startAnimating()
                self.loadData()
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
            self.loadData()
        }
    }
}

extension MessagesListVC: ChatBarDelegate {
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
        if text.isEmpty() {
            let message = L10n("message_cant_send_empty_msg")
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: L10n("common_sure"), style: .cancel)
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }

        let msg = TextMessage(with: text)

        viewModel.sendTextMessage(msg) { [weak self] error in
            self?.tableView.reloadData()
            if error.code != .success {
                self?.showError(error)
            }
        }
    }

    func chatBar(_ chatBar: ChatBar, didSendAudioWith path: String, duration: UInt32) {

        let msg = AudioMessage(with: path, duration: duration)
        viewModel.previewMediaMessage(msg)
        viewModel.sendMediaMessage(msg) { [weak self] error in
            self?.tableView.reloadData()
            if error.code != .success {
                self?.showError(error)
            }
        }
    }

    func chatBar(_ chatBar: ChatBar, didSelectMoreViewWith type: MoreFuncitonType) {
        if type == .photo {
            selectPhotoForSend()
        } else if type == .file {
            selectFileForSend()
        }
    }

    func chatBar(_ chatBar: ChatBar, didStartToRecord recorder: AudioRecorder) {
        audioPlayer.stop()
    }

    func chatBarDidClickDeleteButton(_ chatBar: ChatBar) {
        let messages = viewModel.messages.filter({ $0.isSelected })
        if messages.count == 0 { return }
        // delete selected messages.
        deleteMessages(messages) { [weak self] delete in
            if delete {
                self?.enableMultiSelect(false)
            }
        }
    }
}

// MARK: - MessageCellDelegate
extension MessagesListVC: ImageMessageCellDelegate,
                          UIViewControllerTransitioningDelegate,
                          AudioMessageCellDelegate,
                          VideoMessageCellDelegate,
                          FileMessageDelegate {
    func imageMessageCell(_ cell: ImageMessageCell, didClickImageWith message: ImageMessage) {
        let galleryVC = GalleryVC()
        galleryVC.modalPresentationStyle = .overFullScreen
        galleryVC.transitioningDelegate = self

        let messages = viewModel.messages.filter { $0.type == .image }
        let index = messages.firstIndex(where: { $0 === message }) ?? 0

        galleryVC.content = .init(messages: messages,
                                  currentMessage: message,
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
            for cell in cells where cell.message === galleryVC.content.currentMessage  {
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

    func audioMessageCell(_ cell: AudioMessageCell, didClickWith message: AudioMessage) {
        if FileManager.default.fileExists(atPath: message.fileLocalPath) {
            if !audioPlayer.play(with: message) {
                // show play failed tips.
                HUDHelper.showMessage(L10n("message_audio_play_error_tips"))
            }
        } else {
            print("⚠️Audio File not exist: \(message.fileLocalPath)")
        }
    }

    func videoMessageCell(_ cell: VideoMessageCell, didClickImageWith message: VideoMessage) {
        audioPlayer.stop()
        let playerViewController = MessageAVPlayerViewController()
        playerViewController.setup(with: message)
        present(playerViewController, animated: true) {
            playerViewController.play()
        }
    }

    func fileMessageCell(_ cell: FileMessageCell, didClickImageWith message: FileMessage) {
        previewFile(with: message, cell: cell)
    }

    func messageCell(_ cell: MessageCell, longPressWith message: Message) {
        showOptionsView(cell, message)
    }
}

// MARK: - Send Messages
extension MessagesListVC {

    private func generateFileName() -> String {
        return String(format: "%d%0.0f", UInt32.random(in: 1000...9999), Date().timeIntervalSince1970)
    }

    func sendImageMessage(with url: URL) {

        let filePrefix = ZIMKitManager.shared.imagePath + generateFileName()
        var filePath = ""

        guard var data = try? Data(contentsOf: url) else { return }
        var image = UIImage(data: data)

        let type = data.type

        if type == .GIF {
            filePath = filePrefix + ".gif"
            image = data.gifImage
        }
        else if type == .unknown {
            filePath = filePrefix + ".jpg"
        }
        else {
            filePath = filePrefix + "." + url.pathExtension
        }

        // cache the image
        ImageCache.storeImage(image: image, data: data, for: filePath)

        // preview image message
        let msg = ImageMessage(with: filePath)
        msg.originalImageSize = image?.size ?? CGSize()
        msg.fileName = URL(fileURLWithPath: filePath).lastPathComponent
        msg.fileSize = Int64(data.count)
        if Thread.isMainThread {
            viewModel.previewMediaMessage(msg)
        } else {
            DispatchQueue.main.sync { self.viewModel.previewMediaMessage(msg) }
        }

        // handle image data and send image message.
        DispatchQueue.global().async {

            // just transcode unkonwn image to jpeg.
            if type == .unknown {
                if let newData = image?.jpegData(compressionQuality: 0.75) {
                    data = newData
                }
            }
            // need write to sandbox first, and if send success need delete it.
            try? data.write(to: URL(fileURLWithPath: filePath), options: .atomic)

            self.viewModel.sendMediaMessage(msg) { [weak self] error in
                self?.tableView.reloadData()
                if error.code != .success {
                    self?.showError(error, .image)
                }
            }
        }
    }

    func sendVideoMessage(with url: URL) {

        let filePrefix = ZIMKitManager.shared.videoPath + generateFileName()

        // get preview image and duration of video.
        let videoInfo = VideoTool.getFirstFrameImageAndDuration(with: url)

        var imagePath = ""
        var imageSize: CGSize = .zero
        if let image = videoInfo.0 {
            let imageData = image.pngData()
            imagePath = filePrefix + ".png"
            imageSize = image.size
            // cache the image
            ImageCache.storeImage(image: image, data: imageData, for: imagePath)
        }

        // need preview message first.
        let msg = VideoMessage(
            with: url.relativePath,
            duration: UInt32(videoInfo.1),
            firstFrameLocalPath: imagePath)
        msg.firstFrameSize = imageSize
        if Thread.isMainThread {
            viewModel.previewMediaMessage(msg)
        } else {
            DispatchQueue.main.sync { self.viewModel.previewMediaMessage(msg) }
        }

        // handle video data and send message.
        // need get data first, if switch the thread the url may invalid.
        let data = try? Data(contentsOf: url)
        DispatchQueue.global().async {
            let filePath = filePrefix + "." + url.pathExtension
            // save the video to sandbox.
            FileManager.default.createFile(atPath: filePath, contents: data)
            msg.fileLocalPath = filePath
            self.viewModel.sendMediaMessage(msg) { [weak self] error in
                self?.tableView.reloadData()
                if error.code != .success {
                    self?.showError(error, .video)
                }
            }
        }
    }

    func sendFileMessage(with url: URL) {

        let fileData = try? Data(contentsOf: url)
        let fileName = url.lastPathComponent
        var filePath = ZIMKitManager.shared.filePath + fileName

        if fileData?.count == 0 {
            HUDHelper.showMessage(L10n("message_file_empty_error_tips"))
            return
        }

        /// if the file exist, rename the file.
        /// like `123.txt`, `123(1).txt`, `123(2).txt`
        if FileManager.default.fileExists(atPath: filePath) {
            var i = 0
            while FileManager.default.fileExists(atPath: filePath) {
                i += 1
                var newFileName = url.deletingPathExtension().lastPathComponent + "(\(i))"
                if url.pathExtension.count > 0 {
                    newFileName += "." + url.pathExtension
                }
                filePath = ZIMKitManager.shared.filePath + newFileName
            }
        }

        // preview message first.
        let msg = FileMessage(with: filePath)
        msg.fileName = URL(fileURLWithPath: filePath).lastPathComponent
        let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
        msg.fileSize = size
        if Thread.isMainThread {
            viewModel.previewMediaMessage(msg)
        } else {
            DispatchQueue.main.async { self.viewModel.previewMediaMessage(msg) }
        }

        DispatchQueue.global().async {
            // save the file to sandbox.
            FileManager.default.createFile(atPath: filePath, contents: fileData)
            msg.fileLocalPath = filePath
            self.viewModel.sendMediaMessage(msg) { [weak self] error in
                self?.tableView.reloadData()
                if error.code != .success {
                    self?.showError(error, .file)
                }
            }
        }
    }
}

// MARK: - Private
extension MessagesListVC {
    func scrollToBottom(_ animated: Bool) {
        if viewModel.messages.count > 0 {
            let index = IndexPath(row: viewModel.messages.count-1, section: 0)
            tableView.scrollToRow(at: index, at: .bottom, animated: animated)
        }
    }

    func showError(_ error: ZIMError, _ type: MessageType = .text) {
        if error.code == .networkModuleNetworkError {
            HUDHelper.showMessage(L10n("message_network_anomaly"))
        } else if error.code == .messageModuleFileSizeInvalid {
            if type == .image {
                HUDHelper.showMessage(L10n("message_photo_size_err_tips"))
            } else if type == .video {
                HUDHelper.showMessage(L10n("message_video_size_err_tips"))
            } else if type == .file {
                HUDHelper.showMessage(L10n("message_file_size_err_tips"))
            }
        } else {
            HUDHelper.showMessage(error.message)
        }
    }
}
