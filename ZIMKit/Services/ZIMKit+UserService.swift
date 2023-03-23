//
//  ZIMKit+UserService.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/12/29.
//

import Foundation

extension ZIMKit {
    
    public static var localUser: ZIMKitUser? {
        ZIMKitCore.shared.localUser
    }
    
    public static func connectUser(userID: String,
                                   userName: String? = nil,
                                   avatarUrl: String? = nil,
                                   callback: ConnectUserCallback? = nil) {
        ZIMKitCore.shared.connectUser(userID: userID,
                                      userName: userName,
                                      avatarUrl: avatarUrl,
                                      callback: callback)
    }
    
    public static func disconnectUser() {
        ZIMKitCore.shared.disconnectUser()
    }
    
    public static func queryUserInfo(by userID: String, callback: QueryUserCallback? = nil) {
        ZIMKitCore.shared.queryUserInfo(by: userID, callback: callback)
    }
    
    public static func updateUserAvatarUrl(_ avatarUrl: String,
                                           callback: UserAvatarUrlUpdateCallback? = nil) {
        ZIMKitCore.shared.updateUserAvatarUrl(avatarUrl, callback: callback)
    }
}
