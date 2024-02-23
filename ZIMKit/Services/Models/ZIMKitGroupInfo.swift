//
//  GroupInfo.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/31.
//

import Foundation
import ZIM


public class ZIMKitGroupInfo: NSObject {
    @objc public let id: String

    @objc public var name: String

    @objc public var avatarUrl: String

    @objc public init(with info: ZIMGroupFullInfo) {
        id = info.baseInfo.groupID
        name = info.baseInfo.groupName
        avatarUrl = info.baseInfo.groupAvatarUrl
    }
}
