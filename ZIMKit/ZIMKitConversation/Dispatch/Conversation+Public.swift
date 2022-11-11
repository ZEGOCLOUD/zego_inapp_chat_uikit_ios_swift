//
//  Conversation+Dispatcher.swift
//  Pods-ZIMKitDemo
//
//  Created by Kael Ding on 2022/7/29.
//

import Foundation

extension ConversationDispatcher: DispatchViewControllerProtocol {
    public func viewController() -> UIViewController? {
        switch self {
        case .conversationList:
            return ConversationListVC()
        }
    }
}

extension ConversationActionDispatcher: DispatchActionProtocol {
    public func callAction() -> AnyObject? {
        return nil
    }


}




