//
//  GroupInfo.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/31.
//

import Foundation
import ZIM


/// Group chat info
public struct GroupInfo {
    /// Group ID
    public let id: String

    /// Group name
    public var name: String

    /// Group chat avatar
    public var avatarUrl: String

    public init(with info: ZIMGroupFullInfo) {
        id = info.baseInfo.groupID
        name = info.baseInfo.groupName
        avatarUrl = info.baseInfo.groupAvatarUrl
    }
}
