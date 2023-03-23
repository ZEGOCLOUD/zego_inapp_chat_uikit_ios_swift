//
//  GroupMemberDict.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/2/20.
//

import Foundation

class GroupMemberDict {

    private var data: ThreadSafeDictionary<String, [String: ZIMKitGroupMember]> = .init()
    
    func get(_ groupID: String, _ userID: String) -> ZIMKitGroupMember? {
        let dict = data[groupID]
        return dict?[userID]
    }
    
    func add(_ groupID: String, member: ZIMKitGroupMember) {
        if var dict = data[groupID] {
            if dict.keys.contains(member.id) { return }
            dict[member.id] = member
            data[groupID] = dict
        } else {
            data[groupID] = [member.id: member]
        }
    }
    
    func clear() {
        data.removeAll()
    }
}
