//
//  ZIMKitCore+User.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/9.
//

import Foundation
import ZIM
import ZegoUIKitReport

extension ZIMKitCore {
    func connectUser(userID: String,
                     userName: String? = nil,
                     avatarUrl: String? = nil,
                     callback: ConnectUserCallback? = nil) {
        assert(zim != nil, "Must create ZIM first!!!")
        
        let updateData = ["user_id": userID as AnyObject]
        ReportUtil.sharedInstance().updateCommonParams(updateData)
        
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
            
            let reportData = ["user_id": userID as AnyObject,
                              "user_name": userName as AnyObject,
                              "error": error.code.rawValue as AnyObject,
                              "msg": error.message]
            ReportUtil.sharedInstance().reportEvent("zim/login", paramsDict: reportData)
            callback?(error)
        }
    }
    
    func disconnectUser() {
        zim?.logout()
        clearData()
        ReportUtil.sharedInstance().reportEvent("zim/logout", paramsDict: [:])
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
    
    func updateOtherUserInfo(userID: String,_ avatarUrl: String,_ name: String) {
        if let userInfo = userDict[userID] {
            let user = userInfo
            if !avatarUrl.isEmpty {
                user.avatarUrl = avatarUrl
            }

            if !name.isEmpty {
                user.name = name
            }
            userDict[userID] = user
        }
        
        let messages = messageList.get(userID, type: .peer)
        for kitMessage in messages {
            if kitMessage.info.senderUserID == userID {
                if !name.isEmpty {
                    kitMessage.info.senderUserName = name
                }

                if !avatarUrl.isEmpty {
                    kitMessage.info.senderUserAvatarUrl = avatarUrl
                }
            }
        }
        for kitConversation in conversations {
            if kitConversation.id == userID {
                if !name.isEmpty {
                    kitConversation.name = name
                }

                if !avatarUrl.isEmpty {
                    kitConversation.avatarUrl = avatarUrl
                }
            }
        }
    }
}
