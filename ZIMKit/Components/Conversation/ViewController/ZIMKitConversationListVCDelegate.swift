//
//  ZIMKitConversationListVCDelegate.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/17.
//

import Foundation

@objc public protocol ZIMKitConversationListVCDelegate: AnyObject {
    
    @objc optional
    func conversationList(_ conversationListVC: ZIMKitConversationListVC,
                          didSelectWith conversation: ZIMKitConversation,
                          defaultAction: ()-> ())
}
