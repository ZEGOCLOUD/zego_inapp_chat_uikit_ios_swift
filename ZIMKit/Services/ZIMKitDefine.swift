//
//  ZIMKitDefine.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/12/8.
//

import Foundation
import ZIM

public typealias ConnectUserCallback = (_ error: ZIMError) -> Void

public typealias UserAvatarUrlUpdateCallback = (_ url: String, _ error: ZIMError) -> Void

public typealias CreateGroupCallback = (_ groupInfo: ZIMKitGroupInfo,
                                        _ inviteUserErrors: [ZIMErrorUserInfo],
                                        _ error: ZIMError) -> Void

public typealias JoinGroupCallback = (_ groupInfo: ZIMKitGroupInfo, _ error: ZIMError) -> Void

public typealias QueryUserCallback = (_ userInfo: ZIMKitUser?,
                                      _ error: ZIMError) -> Void

public typealias QueryUserInfoCallback = (_ userInfo: ZIMKitUser?) -> Void

public typealias LeaveGroupCallback = (_ error: ZIMError) -> Void

public typealias InviteUsersToJoinGroupCallback = (_ groupMembers: [ZIMKitGroupMember],
                                                   _ inviteUserErrors: [ZIMErrorUserInfo],
                                                   _ error: ZIMError) -> Void

public typealias DeleteConversationCallback = (_ error: ZIMError) -> Void

public typealias UpdateConversationPinnedStateCallback = (_ error: ZIMError) -> Void

public typealias QueryConversationQueriedCallback = (_ conversation: ZIMKitConversation, _ error: ZIMError) -> Void

public typealias QueryCombineMessageDetailCallback = (_ conversation: [ZIMKitMessage], _ error: ZIMError) -> Void

public typealias MessageReactionAddedCallback = (_ reacation: ZIMMessageReaction, _ error: ZIMError) -> Void

public typealias MessageReactionDeletedCallback = (_ reacation: ZIMMessageReaction, _ error: ZIMError) -> Void

public typealias SetConversationNotificationStatusSetCallback = (_ error: ZIMError) -> Void

public typealias ClearUnreadCountCallback = (_ error: ZIMError) -> Void

public typealias GetConversationListCallback = (_ conversations: [ZIMKitConversation],
                                                _ error: ZIMError) -> Void

public typealias LoadMoreConversationCallback = (_ error: ZIMError) -> Void

public typealias MessageSentCallback = (_ error: ZIMError) -> Void

public typealias revokeMessageCallback = (_ error: ZIMError) -> Void

public typealias replyMessageCallback = (_ error: ZIMError) -> Void

public typealias GetMessageListCallback = (_ conversations: [ZIMKitMessage],
                                           _ hasMoreHistoryMessage: Bool,
                                           _ error: ZIMError) -> Void

public typealias LoadMoreMessageCallback = (_ error: ZIMError) -> Void

public typealias sendCombineMessageCallback = (_ error: ZIMError) -> Void

public typealias QueryGroupInfoCallback = (_ info: ZIMKitGroupInfo,
                                           _ error: ZIMError) -> Void

public typealias QueryGroupMemberInfoCallback = (_ member: ZIMKitGroupMember,
                                                 _ error: ZIMError) -> Void

public typealias QueryGroupMemberListInfoCallback = (_ memberList: [ZIMKitGroupMemberInfo],
                                                     _ nextFlag: Int,
                                                     _ error: ZIMError) -> Void

public typealias GroupUsersInvitedCallback = (_ groupID:String,
                                              _ userList: [ZIMKitGroupMemberInfo],
                                              _ errorUserList: [ZIMKitErrorUserInfo],
                                              _ error: ZIMError) -> Void

public typealias DownloadMediaFileCallback = (_ error: ZIMError) -> Void

public typealias DeleteMessageCallback = (_ error: ZIMError) -> Void

public typealias InsertMessageCallback = (_ message: ZIMKitMessage, _ error: ZIMError) -> Void

public typealias sendMessageOneByOneCallback = () -> Void
