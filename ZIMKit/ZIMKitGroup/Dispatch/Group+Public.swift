//
//  Conversation+Dispatcher.swift
//  Pods-ZIMKitDemo
//
//  Created by Kael Ding on 2022/7/29.
//

import Foundation

extension GroupDispatcher: DispatchViewControllerProtocol {
    public func viewController() -> UIViewController? {
        switch self {
        case let .groupDetail(groupID, groupName):
            return GroupDetailVC(groupID, groupName)
        }
    }
}

extension GroupActionDispatcher: DispatchActionProtocol {
    public func callAction() -> AnyObject? {
        return nil
    }
}



