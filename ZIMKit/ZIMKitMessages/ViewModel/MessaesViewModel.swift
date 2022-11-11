//
//  MessaesViewModel.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/9.
//

import Foundation
import ZIM
import UIKit

typealias queryHistoryCallback = (Bool, Bool, [Message], ZIMError) -> Void

class MessagesViewModel: NSObject {

    /// The handle queue when receive or query messages.
    var handleMessageQueue = DispatchQueue(label: "com.zegocloud.imkit.handleMessageQueue")

    private(set) var conversationID: String
    private(set) var conversationType: ConversationType

    @Observable var messages: [Message] = []
    @Observable var isReceiveNewMessage: Bool = false
    @Observable var isSendingNewMessage: Bool = false

    /// Current connection event.
    @Observable var connectionEvent: ZIMConnectionEvent = .success

    var groupMemberDict = ThreadSafeDictionary<String, ZIMGroupMemberInfo>()
    var groupMemberNextFlag: UInt32 = 0

    var otherUser: ZIMUserFullInfo?

    var isFirstLoad: Bool = true
    var isLoadingData: Bool = false
    var isNoMoreMsg: Bool = false
    var isShowCheckBox: Bool = false

    init(conversationID: String, _ conversationType: ConversationType) {
        self.conversationID = conversationID
        self.conversationType = conversationType
        super.init()
        ZIMKitManager.shared.addZIMEventHandler(self)
    }
}

// MARK: - Public
extension MessagesViewModel {

    func queryHistoryMessage(by type: ConversationType, callback: queryHistoryCallback? = nil) {
        let config = ZIMMessageQueryConfig()
        config.count = 30
        config.nextMessage = messages.first?.zimMsg
        config.reverse = true

        isLoadingData = true
        if messages.count > 0 {
            isFirstLoad = false
        }
        let zimType: ZIMConversationType = type == .peer ? .peer : .group
        ZIMKitManager.shared.zim?.queryHistoryMessage(
            byConversationID: conversationID,
            conversationType: zimType,
            config: config
        ) { [weak self] _, _, zimMessages, error in

            guard let self = self else { return }

            if error.code != .success {
                self.isLoadingData = false
                callback?(self.isFirstLoad, false, [], error)
                return
            }

            self.handleMessageQueue.async {
                var newMessages: [Message] = []
                for msg in zimMessages {
                    let model = MessageFactory.createMessage(with: msg)
                    model.setNeedShowTime(newMessages.last?.timestamp)
                    model.setCellHeight()
                    self.updateMessageUserInfo(with: model)
                    newMessages.append(model)

                    // auto download files
                    self.autoDownloadFiles(with: model)
                }

                if let lastMessage = self.messages.first {
                    lastMessage.setNeedShowTime(newMessages.last?.timestamp)
                    lastMessage.setCellHeight()
                }

                if newMessages.count < config.count {
                    self.isNoMoreMsg = true
                }
                DispatchQueue.main.async {
                    self.messages = newMessages + self.messages
                    // need callback first and then set `isLoadingData` to `false`
                    callback?(self.isFirstLoad, self.isNoMoreMsg, newMessages, error)
                    self.isLoadingData = false
                }
            }
        }
    }

    /// Only use the conversation type is `group`, to query the group member list.
    func queryGroupMemberList(_ callback: ((ZIMError) -> Void)? = nil) {
        let config = ZIMGroupMemberQueryConfig()
        config.nextFlag = groupMemberNextFlag
        config.count = 100

        ZIMKitManager.shared.zim?.queryGroupMemberList(
            byGroupID: conversationID,
            config: config
        ) { [weak self] _, members, nextFlag, error in

            guard let self = self else { return }

            defer {
                callback?(error)
            }
            if error.code != .success { return }

            self.groupMemberNextFlag = nextFlag
            for member in members {
                self.groupMemberDict[member.userID] = member
            }

            if nextFlag == 0 {
                self.updateGroupUserInfoToMessages()
            }
        }
    }

    /// Only use when conversation type is `peer`, to query the user info.
    func queryOtherUserInfo(_ callback: ((ZIMError) -> Void)? = nil) {
        let config = ZIMUsersInfoQueryConfig()
        config.isQueryFromServer = true
        ZIMKitManager.shared.zim?.queryUsersInfo(
            [conversationID],
            config: config
        ) { [weak self] users, _, error in
            guard let self = self else { return }
            if error.code == .success {
                self.otherUser = users.first
                self.updateOtherUserInfoToMessages()
            }
            callback?(error)
        }
    }

    /// Only use when conversation type is `group`, to query the group info.
    func queryGroupInfo(_ callback: ((ZIMGroupFullInfo?, ZIMError) -> Void)? = nil) {
        ZIMKitManager.shared.zim?.queryGroupInfo(byGroupID: conversationID, callback: { info, error in
            callback?(info, error)
        })
    }

    // MARK: - Send Message
    func sendTextMessage(_ message: Message, callback: ((ZIMError) -> Void)? = nil) {

        message.conversationType = conversationType == .peer ? .peer : .group
        message.sentStatus = .sending
        message.direction = .send
        message.timestamp = UInt64(Date().timeIntervalSince1970 * 1000)
        message.senderUserID = ZIMKitManager.shared.userInfo?.id ?? ""
        message.setNeedShowTime(messages.last?.timestamp)
        message.setCellHeight()
        updateMessageUserInfo(with: message)
        self.messages.append(message)
        self.isSendingNewMessage = true

        let config = ZIMMessageSendConfig()
        let sendMsg = message.zimMsg
        let zimType: ZIMConversationType = conversationType == .peer ? .peer : .group
        ZIMKitManager.shared.zim?.send(sendMsg,
                                       toConversationID: conversationID,
                                       conversationType: zimType,
                                       config: config,
                                       notification: nil
        ) { [weak self] zimMessage, error in
            guard let self = self else { return }
            self.handleSentCallback(message, zimMessage, error, callback)
        }
    }

    func sendMediaMessage(_ message: MediaMessage, callback: ((ZIMError) -> Void)? = nil) {

        let config = ZIMMessageSendConfig()
        guard let sendMsg = message.zimMsg as? ZIMMediaMessage else { return }
        let zimType: ZIMConversationType = conversationType == .peer ? .peer : .group
        ZIMKitManager.shared.zim?.send(
            sendMsg,
            toConversationID: conversationID,
            conversationType: zimType,
            config: config,
            progress: { _, _, _ in

            }, callback: { [weak self] zimMessage, error in
                guard let self = self else { return }
                self.handleSentCallback(message, zimMessage, error, callback)
            })
    }

    /// when sending a media message, and may cost much time,
    /// so need preivew first.
    func previewMediaMessage(_ message: MediaMessage) {
        message.conversationType = conversationType == .peer ? .peer : .group
        message.sentStatus = .sending
        message.direction = .send
        message.timestamp = UInt64(Date().timeIntervalSince1970 * 1000)
        message.senderUserID = ZIMKitManager.shared.userInfo?.id ?? ""
        message.setNeedShowTime(messages.last?.timestamp)
        message.setCellHeight()
        updateMessageUserInfo(with: message)
        self.messages.append(message)
        self.isSendingNewMessage = true
    }

    func clearConversationUnreadMessageCount() {
        let zimType: ZIMConversationType = conversationType == .peer ? .peer : .group
        ZIMKitManager.shared.zim?.clearConversationUnreadMessageCount(conversationID, conversationType: zimType, callback: { _, _, _ in

        })
    }

    func downloadMediaMessage(_ message: MediaMessage, callback: ((ZIMError) -> Void)? = nil) {
        guard let zimMsg = message.zimMsg as? ZIMMediaMessage else { return }
        if message.isDownloading { return }
        message.isDownloading = true
        ZIMKitManager.shared.zim?.downloadMediaFile(with: zimMsg, fileType: .originalFile, progress: { _, _, _ in

        }, callback: { msg, error in
            message.isDownloading = false
            if error.code == .success {
                print("✅Download File Success: \(msg.fileName), localID: \(msg.localMessageID)")
                message.fileLocalPath = msg.fileLocalPath
            } else {
                print("❌Download File Failed: \(msg.fileName), localID: \(msg.localMessageID)")
            }
            callback?(error)
        })
    }

    // MARK: - Delete Message
    func deleteMessages(_ messaages: [Message], callback: ((ZIMError) -> Void)? = nil) {
        self.messages = self.messages.filter({ !messaages.contains($0) })
        let zimMessages = messaages.map({ $0.zimMsg })
        let config = ZIMMessageDeleteConfig()
        let zimType: ZIMConversationType = conversationType == .peer ? .peer : .group
        ZIMKitManager.shared.zim?.delete(
            zimMessages,
            conversationID: conversationID,
            conversationType: zimType,
            config: config
        ) { _, _, error in
            callback?(error)
        }
        DispatchQueue.global().async {
            for msg in messaages {
                if let msg = msg as? ImageMessage {
                    ImageCache.removeCache(for: msg.thumbnailDownloadUrl)
                    ImageCache.removeCache(for: msg.largeImageDownloadUrl)
                    ImageCache.removeCache(for: msg.fileLocalPath)
                    if FileManager.default.fileExists(atPath: msg.fileLocalPath) {
                        try? FileManager.default.removeItem(atPath: msg.fileLocalPath)
                    }
                } else if let msg = msg as? MediaMessage {
                    if FileManager.default.fileExists(atPath: msg.fileLocalPath) {
                        try? FileManager.default.removeItem(atPath: msg.fileLocalPath)
                    }
                }
            }
        }
    }
}

// MARK: - Private
extension MessagesViewModel {
    private func updateMessageUserInfo(with message: Message) {
        if message.conversationType == .group {
            let member = groupMemberDict[message.senderUserID]
            message.senderUsername = member?.userName
            message.senderUserAvatar = member?.memberAvatarUrl
            if message.direction == .send && member == nil {
                message.senderUsername = ZIMKitManager.shared.userInfo?.name
                message.senderUserAvatar = ZIMKitManager.shared.userInfo?.avatarUrl
            }
        } else if message.conversationType == .peer {
            if message.direction == .send {
                message.senderUsername = ZIMKitManager.shared.userInfo?.name
                message.senderUserAvatar = ZIMKitManager.shared.userInfo?.avatarUrl
            } else {
                message.senderUsername = otherUser?.baseInfo.userName
                message.senderUserAvatar = otherUser?.userAvatarUrl
            }
        }
    }

    private func updateOtherUserInfoToMessages() {
        let toUpdateMessages = messages.filter { $0.senderUserID == otherUser?.baseInfo.userID }
        toUpdateMessages.forEach { msg in
            msg.senderUsername = otherUser?.baseInfo.userName
            msg.senderUserAvatar = otherUser?.userAvatarUrl
        }
    }

    private func updateGroupUserInfoToMessages() {
        for (userID, user) in groupMemberDict {
            let msgs = messages.filter { $0.senderUserID == userID }
            msgs.forEach { msg in
                msg.senderUsername = user.userName
                msg.senderUserAvatar = user.memberAvatarUrl
            }
        }
    }

    private func handleSentCallback(_ message: Message, _ zimMessage: ZIMMessage, _ error: ZIMError, _ callback: ((ZIMError) -> Void)? = nil) {

        defer {
            callback?(error)
        }

        if error.code == .messageModuleTargetDoseNotExist && conversationType == .peer {
            let content = L10n("message_user_not_exit_please_again", conversationID)
            let systemMessage = SystemMessage(with: content)
            systemMessage.timestamp = zimMessage.timestamp
            systemMessage.setCellHeight()
            if let index = messages.firstIndex(where: { $0 === message }) {
                messages.insert(systemMessage, at: index)
            }
            isSendingNewMessage = true
        }

        let model = MessageFactory.createMessage(with: zimMessage)

        if let index = messages.firstIndex(where: { $0 === message }) {
            messages[index] = model
            if index - 1 >= 0 {
                let lastMessage = messages[index-1]
                model.setNeedShowTime(lastMessage.timestamp)
            }
            model.setCellHeight()
            updateMessageUserInfo(with: model)

            guard let message = message as? VideoMessage,
                  let model = model as? VideoMessage else { return }
            if model.firstFrameLocalPath.count == 0 {
                model.firstFrameLocalPath = message.firstFrameLocalPath
                model.firstFrameSize = message.firstFrameSize
                model.reSetCellHeight()
            }
        }

        // delete local image if send success
        if error.code != .success { return }
        guard let zimMessage = zimMessage as? ZIMImageMessage else { return }
        try? FileManager.default.removeItem(atPath: zimMessage.fileLocalPath)
    }

    private func autoDownloadFiles(with message: Message) {
        guard let message = message as? MediaMessage else { return }
        if message.type != .audio && message.type != .file { return }
        guard let zimMsg = message.zimMsg as? ZIMMediaMessage else { return }
        if FileManager.default.fileExists(atPath: zimMsg.fileLocalPath) { return }
        if zimMsg.fileSize > 1024 * 1024 * 10 { return }
        if zimMsg.fileDownloadUrl.count == 0 { return }

        downloadMediaMessage(message) { [weak self] error in
            if error.code != .success {
                //                #warning("The simple retry logic, will remove in future.")
                /// redownload after 5s, if failed.
                DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
                    self?.autoDownloadFiles(with: message)
                }
            }
        }
    }
}

// MARK: - ZIMEventHandler
extension MessagesViewModel: ZIMEventHandler {

    func zim(_ zim: ZIM, receivePeerMessage messageList: [ZIMMessage], fromUserID: String) {

        if conversationID != fromUserID { return }

        handleReceiveNewMessages(messageList)
    }

    func zim(_ zim: ZIM, receiveGroupMessage messageList: [ZIMMessage], fromGroupID: String) {

        if conversationID != fromGroupID { return }

        handleReceiveNewMessages(messageList)
    }

    func zim(_ zim: ZIM, receiveRoomMessage messageList: [ZIMMessage], fromRoomID: String) {
        if conversationID != fromRoomID { return }

        handleReceiveNewMessages(messageList)
    }

    func zim(_ zim: ZIM, groupMemberStateChanged state: ZIMGroupMemberState, event: ZIMGroupMemberEvent, userList: [ZIMGroupMemberInfo], operatedInfo: ZIMGroupOperatedInfo, groupID: String) {
        for info in userList {
            if state == .enter {
                groupMemberDict[info.userID] = info
            } else {
                groupMemberDict.removeValue(forKey: info.userID)
            }
        }
    }

    func zim(_ zim: ZIM, connectionStateChanged state: ZIMConnectionState, event: ZIMConnectionEvent, extendedData: [AnyHashable : Any]) {
        self.connectionEvent = event
    }

    private func handleReceiveNewMessages(_ messageList: [ZIMMessage]) {

        handleMessageQueue.async {
            // need Ascending
            let messageList = messageList.sorted { $0.timestamp < $1.timestamp }

            var newMessages: [Message] = []
            var lastMessage = self.messages.last
            for msg in messageList {
                let model = MessageFactory.createMessage(with: msg)
                model.setNeedShowTime(lastMessage?.timestamp)
                model.setCellHeight()
                self.updateMessageUserInfo(with: model)
                newMessages.append(model)
                lastMessage = model
                // auto download files
                self.autoDownloadFiles(with: model)
            }
            self.messages.append(contentsOf: newMessages)

            DispatchQueue.main.async {
                self.isReceiveNewMessage = true
            }
        }

        clearConversationUnreadMessageCount()
    }
}
