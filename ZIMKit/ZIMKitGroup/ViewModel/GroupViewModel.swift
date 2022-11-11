//
//  GroupViewModel.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/31.
//

import Foundation
import ZIM

class GroupViewModel {
    var userID: String = ""
    var groupID: String = ""
    var groupName: String = ""
    var groupUserIDs: [String] = []

    func createGroup(_ callback: @escaping (GroupInfo, [ZIMErrorUserInfo], ZIMError) -> Void) {
        let info = ZIMGroupInfo()
        info.groupName = groupName
        ZIMKitManager.shared.zim?.createGroup(info, userIDs: groupUserIDs, callback: { fullInfo, _, errors, error in
            let info = GroupInfo(with: fullInfo)
            callback(info, errors, error)
        })
    }

    func joinGroup(_ callback: @escaping (GroupInfo, ZIMError) -> Void) {
        ZIMKitManager.shared.zim?.joinGroup(groupID, callback: { fullInfo, error in
            let info = GroupInfo(with: fullInfo)
            callback(info, error)
        })
    }
}
