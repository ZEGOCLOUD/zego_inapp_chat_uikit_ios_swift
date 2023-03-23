//
//  GroupMember.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/31.
//

import Foundation
import ZIM

public enum GroupMemberRole {
    case owner
    case member
}

public struct ZIMKitGroupMember {
    public var id: String

    public var name: String

    public var avatarUrl: String?
    
    public var nickName: String
    
    public var role: GroupMemberRole
    
    init(with member: ZIMGroupMemberInfo) {
        id = member.userID
        name = member.userName
        nickName = member.memberNickname
        role = member.memberRole == 1 ? .owner : .member
        avatarUrl = member.memberAvatarUrl
    }
}
