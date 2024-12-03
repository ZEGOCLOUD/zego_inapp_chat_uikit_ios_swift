//
//  ZIMKitCore+Group.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/9.
//

import Foundation
import ZIM

extension ZIMKitCore {
    func createGroup(with groupName: String,
                     groupID: String,
                     inviteUserIDs: [String],
                     callback: CreateGroupCallback? = nil) {
        let info = ZIMGroupInfo()
        info.groupName = groupName
        info.groupID = groupID
        zim?.createGroup(with: info, userIDs: inviteUserIDs, callback: { fullInfo, _, errorUserList, error in
            let info = ZIMKitGroupInfo(with: fullInfo)
            callback?(info, errorUserList, error)
        })
    }
    
    func joinGroup(by groupID: String, callback: JoinGroupCallback? = nil) {
        zim?.joinGroup(by: groupID, callback: { fullInfo, error in
            let info = ZIMKitGroupInfo(with: fullInfo)
            callback?(info, error)
        })
    }
    
    func leaveGroup(by groupID: String, callback: LeaveGroupCallback? = nil) {
        zim?.leaveGroup(by: groupID, callback: { groupID, error in
            callback?(error)
        })
    }
    
    func inviteUsersToJoinGroup(with userIDs: [String],
                                groupID: String,
                                callback: InviteUsersToJoinGroupCallback? = nil) {
        zim?.inviteUsersIntoGroup(with: userIDs, groupID: groupID, callback: { groupID, groupMemberInfos, errorUserInfos, error in
            let members = groupMemberInfos.compactMap { ZIMKitGroupMember(with: $0) }
            callback?(members, errorUserInfos, error)
        })
    }
    
    func queryGroupInfo(by groupID: String,
                        callback: QueryGroupInfoCallback? = nil) {
        zim?.queryGroupInfo(by: groupID, callback: { fullInfo, error in
            let groupInfo = ZIMKitGroupInfo(with: fullInfo)
            callback?(groupInfo, error)
        })
    }
    
    func queryGroupMemberInfo(by userID: String,
                              groupID: String,
                              callback: QueryGroupMemberInfoCallback? = nil) {
        zim?.queryGroupMemberInfo(by: userID, groupID: groupID, callback: { _, zimMemberInfo, error in
            let groupMember = ZIMKitGroupMember(with: zimMemberInfo)
            self.groupMemberDict.add(groupID, member: groupMember)
            self.userDict[userID] = ZIMKitUser(userID: zimMemberInfo.userID, userName: zimMemberInfo.userName)
            callback?(groupMember, error)
        })
    }
  
    func queryGroupMemberListByGroupID(by groupID: String, 
                                       maxCount: Int = 100,
                                       nextFlag: Int,
                                       callback: QueryGroupMemberListInfoCallback? = nil) {
      let config: ZIMGroupMemberQueryConfig = ZIMGroupMemberQueryConfig()
      config.count = UInt32(maxCount)
      config.nextFlag = UInt32(nextFlag)
      zim?.queryGroupMemberList(by: groupID, config: config, callback: { groupID,userList, nextFlag, errorInfo  in
        let memberList = userList.map { ZIMKitGroupMemberInfo(with: $0) }
        callback?(memberList, Int(nextFlag),errorInfo)
      })
    }
  
    func inviteUsersIntoGroup(by groupID: String,
                                 userIDs: [String],
                                 callback: GroupUsersInvitedCallback? = nil) {

      zim?.inviteUsersIntoGroup(with: userIDs, groupID: groupID, callback: { groupID, userList, errorList, errorInfo in
        let memberList = userList.map { ZIMKitGroupMemberInfo(with: $0) }
        let errorMemberList = errorList.map { ZIMKitErrorUserInfo(with: $0) }
        callback?(groupID,memberList,errorMemberList,errorInfo)
      })
    }
}
