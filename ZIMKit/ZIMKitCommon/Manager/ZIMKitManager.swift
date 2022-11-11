//
//  ZIMKitManager.swift
//  ZIMKitCommon
//
//  Created by Kael Ding on 2022/8/1.
//

import Foundation
import ZIM

public protocol ZIMKitManagerDelegate: AnyObject {

    /// Callback for updates on the connection status changes.
    /// The event callback when the connection state changes.
    /// - Parameters:
    ///   - state: the current connection status.
    ///   - event: the event happened. The event that causes the connection status to change.
    func onConnectionStateChange(_ state: ZIMConnectionState, _ event: ZIMConnectionEvent)

    /// Total number of unread messages.
    /// - Parameter totalCount: Total number of unread messages.
    func onTotalUnreadMessageCountChange(_ totalCount: UInt32)
}

extension ZIMKitManagerDelegate {
    func onTotalUnreadMessageCountChange(_ totalCount: UInt32) { }
}

/// Callback for the results that whether the connection is successful.
public typealias ConnectUserCallback = (ZIMError) -> Void

/// Callback for the updates on user avatar changes.
public typealias UserAvatarUrlUpdateCallback = (String, ZIMError) -> Void

/// Callback for the results that whether the group chat is created successfully.
/// - Parameters:
///     - groupInfo: group chat info.
///     - errorUserList: user error list, indicating that a user failed to join the group chat for some reason (e.g., the user does not exist), if the list is empty, indicating that all users have joined the group chat.
///     - errorInfo: error information, which indicates whether the current method is called successfully.
public typealias CreateGroupCallback = (GroupInfo, [ZIMErrorUserInfo], ZIMError) -> Void

/// Callback for the results that whether the group chat is joined successfully.
/// - Parameters:
///     - groupInfo: group chat info.
///     - errorInfo: error information.
public typealias JoinGroupCallback = (GroupInfo, ZIMError) -> Void


public class ZIMKitManager: NSObject {

    public static let shared = ZIMKitManager()

    /// ZIMKitManager delegate declaration
    public weak var delegate: ZIMKitManagerDelegate?

    /// The ZIM instacne
    public fileprivate(set) var zim: ZIM?

    /// Current user info
    public fileprivate(set) var userInfo: UserInfo?

    public lazy var dataPath: String = {
        let path = NSHomeDirectory() + "/Documents/ZIMKitSDK/" + (userInfo?.id ?? "")
        return path
    }()

    private let zimEventHandlers: NSHashTable<ZIMEventHandler> = NSHashTable(options: .weakMemory)


    /// Initialize the ZIMKit.
    /// You will need to initialize the ZIMKit SDK before calling methods.
    /// - Parameters:
    ///   - appID: appID. To get this, go to ZEGOCLOUD Admin Console (https://console.zegocloud.com/).
    ///   - appSign: appSign. To get this, go to ZEGOCLOUD Admin Console (https://console.zegocloud.com/).
    public func initWith(appID: UInt32, appSign: String) {
        let config = ZIMAppConfig()
        config.appID = appID
        config.appSign = appSign
        zim = ZIM.create(with: config)
        zim?.setEventHandler(self)
    }

    /// Connects user to the ZIMKit server.
    ///  This method can only be used after calling the [initWith:] method and before you calling any other methods.
    /// - Parameters:
    ///   - userInfo: user info
    ///   - callback: callback for the results that whether the connection is successful.
    public func connectUser(userInfo: UserInfo, callback: ConnectUserCallback?) {
        assert(zim != nil, "Must create ZIM first!!!")
        self.userInfo = userInfo
        let zimUserInfo = ZIMUserInfo()
        zimUserInfo.userID = userInfo.id
        zimUserInfo.userName = userInfo.name
        zim?.login(with: zimUserInfo, token: "", callback: { error in
            if let userAvatarUrl = userInfo.avatarUrl {
                self.updateUserAvatarUrl(userAvatarUrl) { _, error in
                    if error.code == .success {
                        print("Update user's avatar success.")
                    }
                }
            }
            guard let callback = callback else { return }
            callback(error)
        })
    }

    /// Disconnects current user from ZIMKit server.
    public func disconnectUser() {
        zim?.logout()
    }

    /// Update the user avatar
    /// After a successful connection, you can change the user avatar as needed.
    /// - Parameters:
    ///   - avatarUrl: avatar URL.
    ///   - callback: callback for the results that whether the user avatar is updated successfully.
    public func updateUserAvatarUrl(_ avatarUrl: String, callback: UserAvatarUrlUpdateCallback?) {
        zim?.updateUserAvatarUrl(avatarUrl, callback: { url, error in
            self.userInfo?.avatarUrl = url
            guard let callback = callback else { return }
            callback(url, error)
        })
    }


    /// Create a group chat
    /// You can choose multiple users besides yourself to start a group chat.
    /// - Parameters:
    ///   - groupName: group name.
    ///   - userIDs: user ID list.
    ///   - callback: callback for the results that whether the group chat is created successfully.
    public func createGroup(groupName: String, userIDs: [String], callback: CreateGroupCallback?) {
        let info = ZIMGroupInfo()
        info.groupName = groupName
        zim?.createGroup(info, userIDs: userIDs, callback: { fullInfo, _, errors, error in
            let info = GroupInfo(with: fullInfo)
            callback?(info, errors, error)
        })
    }


    /// Join the group chat
    /// - Parameters:
    ///   - groupID: group ID
    ///   - callback: callback for the results that whether the group chat is joined successfully.
    public func joinGroup(by groupID: String, callback: JoinGroupCallback?) {
        zim?.joinGroup(groupID, callback: { fullInfo, error in
            let info = GroupInfo(with: fullInfo)
            callback?(info, error)
        })
    }

    public func addZIMEventHandler(_ eventHandler: ZIMEventHandler) {
        zimEventHandlers.add(eventHandler)
    }
}

extension ZIMKitManager {

}

// MARK: - ZIMEventHandler
extension ZIMKitManager: ZIMEventHandler {
    public func zim(_ zim: ZIM, connectionStateChanged state: ZIMConnectionState, event: ZIMConnectionEvent, extendedData: [AnyHashable : Any]) {
        for eventHandler in zimEventHandlers.allObjects {
            eventHandler.zim?(zim, connectionStateChanged: state, event: event, extendedData: extendedData)
        }
        delegate?.onConnectionStateChange(state, event)
    }

    // MARK: - ZIMEventHandler -- Conversation
    public func zim(_ zim: ZIM, conversationChanged conversationChangeInfoList: [ZIMConversationChangeInfo]) {
        for eventHandler in zimEventHandlers.allObjects {
            eventHandler.zim?(zim, conversationChanged: conversationChangeInfoList)
        }
    }

    public func zim(_ zim: ZIM, conversationTotalUnreadMessageCountUpdated totalUnreadMessageCount: UInt32) {
        for eventHandler in zimEventHandlers.allObjects {
            eventHandler.zim?(zim, conversationTotalUnreadMessageCountUpdated: totalUnreadMessageCount)
        }
        delegate?.onTotalUnreadMessageCountChange(totalUnreadMessageCount)
    }

    // MARK: - ZIMEventHandler -- Message
    public func zim(_ zim: ZIM, receivePeerMessage messageList: [ZIMMessage], fromUserID: String) {
        for eventHandler in zimEventHandlers.allObjects {
            eventHandler.zim?(zim, receivePeerMessage: messageList, fromUserID: fromUserID)
        }
    }

    public func zim(_ zim: ZIM, receiveGroupMessage messageList: [ZIMMessage], fromGroupID: String) {
        for eventHandler in zimEventHandlers.allObjects {
            eventHandler.zim?(zim, receiveGroupMessage: messageList, fromGroupID: fromGroupID)
        }
    }

    public func zim(_ zim: ZIM, receiveRoomMessage messageList: [ZIMMessage], fromRoomID: String) {
        for eventHandler in zimEventHandlers.allObjects {
            eventHandler.zim?(zim, receiveRoomMessage: messageList, fromRoomID: fromRoomID)
        }
    }

    public func zim(_ zim: ZIM,
                    groupMemberStateChanged state: ZIMGroupMemberState,
                    event: ZIMGroupMemberEvent,
                    userList: [ZIMGroupMemberInfo],
                    operatedInfo: ZIMGroupOperatedInfo,
                    groupID: String) {
        for eventHandler in zimEventHandlers.allObjects {
            eventHandler.zim?(zim,
                              groupMemberStateChanged: state,
                              event: event,
                              userList: userList,
                              operatedInfo: operatedInfo,
                              groupID: groupID)
        }
    }
}
