//
//  ZIMKitUser.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/9.
//

import Foundation
import ZIM

public struct ZIMKitUser {
    public var id: String

    public var name: String
    
    public var avatarUrl: String?

    public init(userID: String, userName: String, avatarUrl: String? = nil) {
        self.id = userID
        self.name = userName
        self.avatarUrl = avatarUrl
    }
    
    init(_ zimUserInfo: ZIMUserFullInfo) {
        self.id = zimUserInfo.baseInfo.userID
        self.name = zimUserInfo.baseInfo.userName
        self.avatarUrl = zimUserInfo.userAvatarUrl
    }
}
