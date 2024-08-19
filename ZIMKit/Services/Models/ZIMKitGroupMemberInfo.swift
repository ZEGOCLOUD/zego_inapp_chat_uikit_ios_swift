//
//  ZIMKitGroupMemberInfo.swift
//  ZIMKit
//
//  Created by zego on 2024/7/25.
//

import UIKit
import ZIM


@objc public enum ZIMKitGroupMemberInfoRole: UInt {
    case owner = 1
    case manager
    case member
    case robot
}

@objc public enum ZIMKitGroupEnterType: UInt {
    case unKnown = 0
    case created
    case applyJoin
    case joined
    case invited
    case invite_apply
}


public class ZIMKitErrorUserInfo: NSObject {
  @objc public var userID: String?
  @objc public var reason: Int
  
  init(with member: ZIMErrorUserInfo) {
      userID = member.userID
      reason = Int(member.reason)
  }
}

public class ZIMKitGroupMemberInfo: NSObject {
    @objc public var memberNickname: String?
    
    @objc public var memberRole: ZIMKitGroupMemberInfoRole = .member
    @objc public var enterType: ZIMKitGroupEnterType = .unKnown
    @objc public var enterTime: CLongLong = 0
    @objc public var userAvatarUrl: String = ""
    
    @objc public var muteExpiredTime: CLongLong = 0 //群成员禁言过期时间。为 0 时即不禁言，为 -1 时即永久禁言。
    @objc public var userID: String = ""
    @objc public var userName: String = ""
    @objc public var operatedUser: ZIMKitUser?
    
    override init() {
        
    }
    
    init(with member: ZIMGroupMemberInfo) {
        memberNickname = member.memberNickname
        memberRole = member.memberRole == 1 ? .owner : (member.memberRole == 2 ? .manager : .member)
        enterType = ZIMKitGroupEnterType(rawValue: member.groupEnterInfo.enterType.rawValue) ?? .unKnown
        userAvatarUrl = member.userAvatarUrl
        enterTime = member.groupEnterInfo.enterTime
        muteExpiredTime = member.muteExpiredTime
        userID = member.userID
        userName = member.userName
        operatedUser = ZIMKitUser(userID: member.groupEnterInfo.operatedUser?.userID ?? "", userName: member.groupEnterInfo.operatedUser?.userName ?? "")
    }
}
