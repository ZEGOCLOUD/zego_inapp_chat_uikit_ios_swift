//
//  GroupInfo.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/31.
//

import Foundation
import ZIM


public struct ZIMKitGroupInfo {
    public let id: String

    public var name: String

    public var avatarUrl: String

    public init(with info: ZIMGroupFullInfo) {
        id = info.baseInfo.groupID
        name = info.baseInfo.groupName
        avatarUrl = info.baseInfo.groupAvatarUrl
    }
}
