//
//  ZIMKit+UserService.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/12/29.
//

import Foundation

extension ZIMKit {
    
    @objc public static var localUser: ZIMKitUser? {
        ZIMKitCore.shared.localUser
    }
    
    @objc public static func connectUser(userID: String,
                                   userName: String? = nil,
                                   avatarUrl: String? = nil,
                                   callback: ConnectUserCallback? = nil) {
        ZIMKitCore.shared.connectUser(userID: userID,
                                      userName: userName,
                                      avatarUrl: avatarUrl,
                                      callback: callback)
    }
    
    @objc public static func disconnectUser() {
        ZIMKitCore.shared.disconnectUser()
    }
    
    @objc public static func queryUserInfo(by userID: String, callback: QueryUserCallback? = nil) {
        ZIMKitCore.shared.queryUserInfo(by: userID, callback: callback)
    }
    
    @objc public static func updateUserAvatarUrl(_ avatarUrl: String,
                                           callback: UserAvatarUrlUpdateCallback? = nil) {
        ZIMKitCore.shared.updateUserAvatarUrl(avatarUrl, callback: callback)
    }
  
    @objc public static func queryUserInfoFromLocalCache(userID: String,
                                                         groupID:String = "",
                                           callback: QueryUserInfoCallback? = nil) {
        ZIMKitCore.shared.queryUserInfoFromLocalCache(userID: userID, groupID:groupID,callback: callback)
    }
    
    @objc public static func updateOtherUserInfo(userID: String,_ avatarUrl: String,_ name: String) {
        ZIMKitCore.shared.updateOtherUserInfo(userID: userID, avatarUrl, name)
    }
}
