//
//  MessaesViewModel.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/9.
//

import Foundation
import ZIM
import UIKit

class MessageListViewModel: NSObject {
    
    /// The handle queue when receive or query messages.
    var handleMessageQueue = DispatchQueue(label: "com.zegocloud.imkit.handleMessageQueue")
    
    private(set) var conversationID: String
    private(set) var conversationType: ZIMConversationType
    
    @ZIMKitObservable var messageViewModels: [MessageViewModel] = []
    @ZIMKitObservable var isReceiveNewMessage: Bool = false
    @ZIMKitObservable var isMessageNewReactionIndexPath: IndexPath?
    @ZIMKitObservable var isSendingNewMessage: Bool = false
    @ZIMKitObservable var isHistoryMessageLoaded: Bool = false
    @ZIMKitObservable var isRevokeMessageIndexPath: IndexPath?
    @ZIMKitObservable var deleteMessages: [MessageViewModel] = []
    @ZIMKitObservable var connectionEvent: ZIMConnectionEvent = .success
    
    var isFirstLoad: Bool = true
    var isLoadingData: Bool = false
    var isNoMoreMsg: Bool = false
    var isShowCheckBox: Bool = false

    init(conversationID: String, _ conversationType: ZIMConversationType) {
        self.conversationID = conversationID
        self.conversationType = conversationType
        super.init()
        ZIMKit.registerZIMKitDelegate(self)
    }
}

// MARK: - Public
extension MessageListViewModel {
    
    func getMessageList(_ callback: ((ZIMError) -> Void)?) {
        isLoadingData = true
        ZIMKit.getMessageList(with: conversationID, type: conversationType) { [weak self] messages, hasMoreHistoryMessage, error in
            if error.code != .ZIMErrorCodeSuccess {
                callback?(error)
                self?.isLoadingData = false
                return
            }
            
            guard let self = self else { return }
            self.handleMessageQueue.async {
                self.isNoMoreMsg = !hasMoreHistoryMessage
                self.handleLoadedHistoryMessages(messages)
                DispatchQueue.main.async {
                    callback?(error)
                    self.isLoadingData = false
                }
            }
        }
    }
    
    func loadMoreMessages(_ callback: ((ZIMError) -> Void)?) {
        if isLoadingData { return }
        isLoadingData = true
        ZIMKit.loadMoreMessage(with: conversationID, type: conversationType) { [weak self] error in
            self?.isLoadingData = false
            callback?(error)
        }
    }
    
    
    /// Only use when conversation type is `peer`, to query the user info.
    func queryOtherUserInfo(_ callback: ((ZIMKitUser?, ZIMError) -> Void)? = nil) {
        ZIMKit.queryUserInfo(by: conversationID) { userInfo, error in
            callback?(userInfo, error)
        }
    }
    
    /// Only use when conversation type is `group`, to query the group info.
    func queryGroupInfo(_ callback: ((ZIMKitGroupInfo?, ZIMError) -> Void)? = nil) {
        ZIMKit.queryGroupInfo(by: conversationID) { groupInfo, error in
            callback?(groupInfo, error)
        }
    }
    
    func queryMessageUserInfo(_ userID: String, callback: ((ZIMError) -> ())? = nil) {
        if conversationType == .peer {
            ZIMKit.queryUserInfo(by: userID) { [weak self] user, error in
                self?.updateMessageUserInfo(with: userID,
                                            name: user?.name,
                                            avatarUrl: user?.avatarUrl)
                callback?(error)
            }
        } else {
            ZIMKit.queryGroupMemberInfo(by: userID, groupID: conversationID) { [weak self] member, error in
                self?.updateMessageUserInfo(with: userID,
                                            name: member.name,
                                            avatarUrl: member.avatarUrl)
                callback?(error)
            }
        }
    }
    
    func clearConversationUnreadMessageCount() {
        ZIMKit.clearUnreadCount(for: conversationID, type: conversationType)
    }
    
    func downloadMediaMessage(_ viewModel: MediaMessageViewModel, callback: ((ZIMError) -> Void)? = nil) {
        if viewModel.isDownloading { return }
        viewModel.isDownloading = true
        let message = viewModel.message
        ZIMKit.downloadMediaFile(with: message) { error in
            viewModel.isDownloading = false
            if error.code == .ZIMErrorCodeSuccess {
                //                print("✅Download File Success: \(message.fileName), localID: \(message.info.localMessageID)")
            } else {
                print("❌Download File Failed: \(message.fileName), localID: \(message.info.localMessageID)")
            }
            callback?(error)
        }
    }
    
    // MARK: - Delete Message
    func deleteMessages(_ viewModels: [MessageViewModel], callback: ((ZIMError) -> Void)? = nil) {
        let messages = viewModels.compactMap({ $0.message })
        if messages.count == 0 { return }
        ZIMKit.deleteMessage(messages) { error in
            callback?(error)
        }
        DispatchQueue.global().async {
            for message in messages {
                if message.type == .image {
                    ImageCache.removeCache(for: message.imageContent.thumbnailDownloadUrl)
                    ImageCache.removeCache(for: message.imageContent.largeImageDownloadUrl)
                    ImageCache.removeCache(for: message.imageContent.fileLocalPath)
                    if FileManager.default.fileExists(atPath: message.fileLocalPath) {
                        try? FileManager.default.removeItem(atPath: message.fileLocalPath)
                    }
                } else if FileManager.default.fileExists(atPath: message.fileLocalPath) {
                    try? FileManager.default.removeItem(atPath: message.fileLocalPath)
                }
            }
        }
    }
    
    func revokeMessage(_ messageModel: MessageViewModel, callback: ((ZIMError) -> Void)? = nil) {
        ZIMKit.revokeMessage(messageModel.message) {[weak self] error in
            if error.code.rawValue == 0 {
                self?.modifyRevokeMessage(viewModels: [messageModel])
            }
            print("revokeMessage  code = \(error.code)")
        }
    }
    
    //MARK: Customer
    func modifyRevokeMessage(viewModels:[MessageViewModel]) {
        let indexPaths: [IndexPath] = viewModels.compactMap { viewModel in
            guard let row = self.messageViewModels.firstIndex(of: viewModel) else { return nil }
            return IndexPath(row: row, section: 0)
        }
        
//        let revokeExtendedData:[String:String] = ["revokeUserName":ZIMKit.localUser?.name ?? "","revokeUserID" : ZIMKit.localUser?.id ?? ""]
//        
//        let jsonString: String = zimKit_convertDictToString(dict: revokeExtendedData as [String :AnyObject]) ?? ""
//        
        for (_,indexPath) in indexPaths.enumerated() {
            let revokeMessage = ZIMKitMessage(with: ZIMRevokeMessage())
            let revokeMessageModel = MessageViewModelFactory.createMessage(with: revokeMessage)
            revokeMessageModel.message.type = .revoke
            revokeMessageModel.message.zim = ZIMRevokeMessage()
            revokeMessageModel.message.info.senderUserID = ZIMKit.localUser?.id ?? ""
//            revokeMessageModel.message.revokeExtendedData = jsonString

            self.messageViewModels[indexPath.row] = revokeMessageModel
            DispatchQueue.main.async {
                self.isRevokeMessageIndexPath = indexPath
            }
        }
    }
    func insertMessageToLocalCache(message:ZIMKitMessage) {
        let model = MessageViewModelFactory.createMessage(with: message)
        model.setCellHeight()
        model.setNeedShowTime(UInt64(Date().timeIntervalSince1970) * 1000)
        self.messageViewModels.append(model)
        DispatchQueue.main.async {
            self.isReceiveNewMessage = true
        }
    }
}

// MARK: - Private
extension MessageListViewModel {
    
    private func handleReceiveNewMessages(_ messageList: [ZIMKitMessage]) {
        
        handleMessageQueue.async { [self] in
            // need Ascending
            let messageList = messageList.sorted { $0.info.timestamp < $1.info.timestamp }
            
            var newMessages: [MessageViewModel] = []
            var lastMessage = self.messageViewModels.last
            for msg in messageList {
                
                let messageContent: String = msg.textContent.content
                let orderKey:Int64 = msg.info.orderKey
                let timestamp:UInt64 = msg.info.timestamp
                ZIMKitLogI(filterName: "ZIMKit:MessageListViewModel", format: "handleReceiveNewMessages, content=%@, orderKey=%lld, timestamp=%lld", arguments: messageContent, orderKey, timestamp)
                
                let model = MessageViewModelFactory.createMessage(with: msg)
                model.setNeedShowTime(lastMessage?.message.info.timestamp)
                model.setCellHeight()
                newMessages.append(model)
                lastMessage = model
                // auto download files
                self.autoDownloadFiles(with: model)
            }
            self.messageViewModels.append(contentsOf: newMessages)
//            self.messageViewModels = removeDuplicates(from: self.messageViewModels)
            removeLoadingMessage()
            DispatchQueue.main.async {
                self.isReceiveNewMessage = true
            }
        }
        clearConversationUnreadMessageCount()
    }
    
    func removeLoadingMessage() {
        if ZIMKit().imKitConfig.advancedConfig != nil && ((ZIMKit().imKitConfig.advancedConfig?.keys.contains(ZIMKitAdvancedKey.showLoadingWhenSend)) != nil) {
            self.messageViewModels = self.messageViewModels.filter { viewModel in
                viewModel.message.type != .text || viewModel.message.textContent.content != "[...]"
            }
        }
        
    }
    
    func removeDuplicates(from models: [MessageViewModel]) -> [MessageViewModel] {
        var uniqueModels = [MessageViewModel]()
        for model in models {
            if model.message.type == .custom || model.message.type == .system {
                if !uniqueModels.contains(where: { $0.message.zim?.localMessageID == model.message.zim?.localMessageID }) {
                    uniqueModels.append(model)
                }
            } else {
                if
                    !uniqueModels.contains(where: { $0.message.zim?.messageID == model.message.zim?.messageID }) {
                    uniqueModels.append(model)
                }
            }
            
        }
        return uniqueModels
    }
    
    private func handleSentCallback(_ message: ZIMKitMessage) {
        handleMessageQueue.async { [self] in
//            let messageContent: String = message.textContent.content
//            let orderKey:Int64 = message.info.orderKey
//            let timestamp:UInt64 = message.info.timestamp
//            ZIMKitLogI(filterName: "MessageListViewModel", format: "handleSentCallback, content=%@, orderKey=%lld, timestamp=%lld", arguments: messageContent, orderKey, timestamp)
            
                guard let index = self.messageViewModels.firstIndex(where: { $0.message == message }) else {
                    handleReceiveNewMessages([message])
                    return
                }
                let viewModel = self.messageViewModels[index]
                if index - 1 >= 0 {
                    let lastViewModel = self.messageViewModels[index-1]
                    viewModel.setNeedShowTime(lastViewModel.message.info.timestamp)
                }
                viewModel.reSetCellHeight()
            }
            
            DispatchQueue.main.async { [self] in
                isSendingNewMessage = (message.type == .image || message.type == .video) ? false : true
        }
    }
    
    private func handleLoadedHistoryMessages(_ messages: [ZIMKitMessage]) {
        var newMessages: [MessageViewModel] = []
        for message in messages {
            let viewModel = MessageViewModelFactory.createMessage(with: message)
            viewModel.setNeedShowTime(newMessages.last?.message.info.timestamp)
            viewModel.setCellHeight()
            newMessages.append(viewModel)
            autoDownloadFiles(with: viewModel)
        }
        if let lastMessageVM = messageViewModels.first {
            lastMessageVM.setNeedShowTime(newMessages.last?.message.info.timestamp)
            lastMessageVM.setCellHeight()
        }
        messageViewModels = newMessages + messageViewModels
        messageViewModels = removeDuplicates(from: messageViewModels)
    }
    
    private func autoDownloadFiles(with viewModel: MessageViewModel) {
        let message = viewModel.message
        if message.type != .audio && message.type != .file { return }
        if FileManager.default.fileExists(atPath: message.fileLocalPath) { return }
        if message.fileSize > 1024 * 1024 * 10 { return }
        if message.fileDownloadUrl.count == 0 { return }
        
        guard let viewModel = viewModel as? MediaMessageViewModel else { return }
        downloadMediaMessage(viewModel) { [weak self] error in
            if error.code != .ZIMErrorCodeSuccess {
                //                #warning("The simple retry logic, will remove in future.")
                /// redownload after 5s, if failed.
                DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
                    self?.autoDownloadFiles(with: viewModel)
                }
            }
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

// MARK: - ZIMEventHandler
extension MessageListViewModel: ZIMKitDelegate {
    
    func onConnectionStateChange(_ state: ZIMConnectionState, _ event: ZIMConnectionEvent) {
        self.connectionEvent = event
    }
    
    func onMessageReceived(_ conversationID: String, type: ZIMConversationType, messages: [ZIMKitMessage]) {
        if self.conversationID != conversationID || self.conversationType != type {
            return
        }
        if messages.count == 0 { return }
        handleReceiveNewMessages(messages)
    }
    
    func onHistoryMessageLoaded(_ conversationID: String, type: ZIMConversationType, messages: [ZIMKitMessage]) {
        if self.conversationID != conversationID || self.conversationType != type {
            return
        }
        
        if messages.count == 0 {
            isNoMoreMsg = true
        }
        handleMessageQueue.async {
            if messages.count > 0 {
                self.handleLoadedHistoryMessages(messages)
            }
            DispatchQueue.main.async {
                self.isHistoryMessageLoaded = true
            }
        }
    }
    
    func onMessageDeleted(_ conversationID: String, type: ZIMConversationType, messages: [ZIMKitMessage]) {
        if self.conversationID != conversationID || self.conversationType != type {
            return
        }
        deleteMessages = messageViewModels.filter({ messages.contains($0.message) })
        messageViewModels = messageViewModels.filter({ !messages.contains($0.message) })
    }
    
    func onMessageSentStatusChanged(_ message: ZIMKitMessage) {
        if conversationID != message.info.conversationID ||
            conversationType != message.info.conversationType {
            return
        }
        if message.info.sentStatus == .sending {
            handleReceiveNewMessages([message])
        } else {
            handleSentCallback(message)
        }
    }
    
    func onMediaMessageUploadingProgressUpdated(_ message: ZIMKitMessage, uploadProgress: CGFloat) {
        for (_,model) in messageViewModels.enumerated() {
            if model.message.info.localMessageID == message.info.localMessageID {
                guard let mediaViewModel = model as? MediaMessageViewModel else { return }
                mediaViewModel.uploadProgress = uploadProgress
            }
        }
    }
    
    func onMediaMessageDownloadingProgressUpdated(_ message: ZIMKitMessage, isFinished: Bool) {
        if isFinished {
            handleSentCallback(message)
        }
    }
    
    func onMessageRevoked(_ messages: [ZIMRevokeMessage]) {
        
        for(_,revokedMessage) in messages.enumerated() {
            
            for(index,localMessage) in self.messageViewModels.enumerated() {
                if revokedMessage.messageID == localMessage.message.zim?.messageID {
                    let newMessage = ZIMKitMessage(with: revokedMessage)
                    let newRevokeMessage = MessageViewModelFactory.createMessage(with: newMessage)
                    self.messageViewModels[index] = newRevokeMessage
                    DispatchQueue.main.async {
                        self.isRevokeMessageIndexPath = IndexPath(row: index, section: 0)
                    }
                }
            }
        }
    }
    
    func onMessageReactionsChanged(_ reactions: [ZIMMessageReaction]) {
        var indexPath:IndexPath = IndexPath(row: 1, section: 0)
        for(_,reaction) in reactions.enumerated() {
            for(messageIndex,localMessage) in self.messageViewModels.enumerated() {
                if reaction.messageID == localMessage.message.zim?.messageID && reaction.conversationID == localMessage.message.zim?.conversationID {
                    var containReaction = false
                    for (index,localReaction) in localMessage.message.reactions.enumerated() {
                        
                        for (_,userInfo) in localReaction.userList.enumerated() {
                            updateUserName(userID: userInfo.userID)
                        }
                        if localReaction.reactionType == reaction.reactionType {
                            containReaction = true
                            localMessage.message.reactions[index] = reaction
                            if reaction.totalCount == 0 {
                                localMessage.message.reactions.remove(at: index)
                            }
//                            break
                        }
                    }
                    if containReaction {
                        
                    } else {
                        localMessage.message.reactions.append(reaction)
                    }
                    localMessage.message.zim?.reactions = localMessage.message.reactions
                    indexPath = IndexPath(row: messageIndex, section: 0)
//                    break
                }
            }
        }
        DispatchQueue.main.async {
            self.isMessageNewReactionIndexPath = indexPath
        }
    }
    
    private func updateUserName(userID:String) {
        ZIMKit.queryUserInfoFromLocalCache(userID: userID) { userInfo in
            if userInfo!.name.count > 0 {
               
            } else {
                ZIMKit.queryUserInfo(by: userID) { userInfo, error in
                    
                }
            }
        }
    }
}
