//
//  ZIMKitCore+User.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/9.
//

import Foundation
import ZIM

extension ZIMKitCore {
    func connectUser(userID: String,
                     userName: String? = nil,
                     avatarUrl: String? = nil,
                     callback: ConnectUserCallback? = nil) {
        assert(zim != nil, "Must create ZIM first!!!")
        let zimUserInfo = ZIMUserInfo()
        zimUserInfo.userID = userID
        zimUserInfo.userName = userName ?? ""
        zim?.login(with: zimUserInfo) { [weak self] error in
            if error.code == .ZIMErrorCodeNetworkModuleUserHasAlreadyLogged {
                error.code = .ZIMErrorCodeSuccess
                error.message = ""
            }
            if error.code == .ZIMErrorCodeSuccess {
                self?.localUser = ZIMKitUser(userID: userID, userName: userName ?? "", avatarUrl: avatarUrl)
                self?.userDict[userID] = self?.localUser
            }
            if let userAvatarUrl = avatarUrl {
                self?.updateUserAvatarUrl(userAvatarUrl, callback: nil)
            }
            callback?(error)
        }
    }
    
    func disconnectUser() {
        zim?.logout()
        clearData()
    }
    
    func queryUserInfo(by userID: String, callback: QueryUserCallback? = nil) {
        let config = ZIMUsersInfoQueryConfig()
        config.isQueryFromServer = true
        zim?.queryUsersInfo(by: [userID], config: config, callback: { [weak self] fullInfos, errorUserInfos, error in
            var userInfo: ZIMKitUser?
            if let fullUserInfo = fullInfos.first {
                userInfo = ZIMKitUser(fullUserInfo)
            }
            self?.userDict[userID] = userInfo
            callback?(userInfo, error)
        })
    }
    
      func queryUserInfoFromLocalCache(userID:String, groupID:String,callback: QueryUserInfoCallback? = nil)  {
        var user: ZIMKitUser = ZIMKitUser(userID: userID, userName: "")
          if let userInfo = userDict[userID] {
                user = userInfo
          } else {
            let member = groupMemberDict.get(groupID,
                                             userID)
              user.name = member?.name ?? ""
              user.id = userID
              user.avatarUrl = member?.avatarUrl ?? ""
          }
          callback?(user)
        }
  
    func updateUserAvatarUrl(_ avatarUrl: String,
                             callback: UserAvatarUrlUpdateCallback? = nil) {
        zim?.updateUserAvatarUrl(avatarUrl, callback: { url, error in
            self.localUser?.avatarUrl = url
            callback?(url, error)
        })
    }
}
