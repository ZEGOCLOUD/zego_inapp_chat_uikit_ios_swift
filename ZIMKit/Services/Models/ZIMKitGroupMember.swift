//
//  GroupMember.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/31.
//

import Foundation
import ZIM

@objc public enum GroupMemberRole: UInt {
    case owner
    case member
}

public class ZIMKitGroupMember: NSObject {
    @objc public var id: String

    @objc public var name: String

    @objc public var avatarUrl: String?
    
    @objc public var nickName: String
    
    @objc public var role: GroupMemberRole
    
    init(with member: ZIMGroupMemberInfo) {
        id = member.userID
        name = member.userName
        nickName = member.memberNickname
        role = member.memberRole == 1 ? .owner : .member
        avatarUrl = member.memberAvatarUrl
    }
}
