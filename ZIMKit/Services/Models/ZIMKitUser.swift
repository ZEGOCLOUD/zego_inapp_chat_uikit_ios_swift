//
//  ZIMKitUser.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/9.
//

import Foundation
import ZIM

public class ZIMKitUser: NSObject {
    @objc public var id: String

    @objc public var name: String
    
    @objc public var avatarUrl: String?

    @objc public init(userID: String, userName: String, avatarUrl: String? = nil) {
        self.id = userID
        self.name = userName
        self.avatarUrl = avatarUrl
    }
    
    @objc init(_ zimUserInfo: ZIMUserFullInfo) {
        self.id = zimUserInfo.baseInfo.userID
        self.name = zimUserInfo.baseInfo.userName
        self.avatarUrl = zimUserInfo.userAvatarUrl
    }
}
