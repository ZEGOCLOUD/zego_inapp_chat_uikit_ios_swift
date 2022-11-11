//
//  GroupMember.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/31.
//

import Foundation
import ZIM

enum GroupMemberRole {
    case owner
    case member
}

struct GroupMember {
    let userID: String
    var userName: String
    var nickName: String
    var role: GroupMemberRole
    var avatarUrl: String
    init(with member: ZIMGroupMemberInfo) {
        userID = member.userID
        userName = member.userName
        nickName = member.memberNickname
        role = member.memberRole == 1 ? .owner : .member
        avatarUrl = member.memberAvatarUrl
    }
}
