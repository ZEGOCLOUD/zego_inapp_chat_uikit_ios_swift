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
    @objc optional
    func shouldDeleteItem(_ conversationListVC: ZIMKitConversationListVC,
                          didSelectWith conversation: ZIMKitConversation,
                          withErrorCode code:UInt,
                          withErrorMsg msg:String)
    @objc optional
    func shouldHideSwipePinnedItem(_ conversationListVC: ZIMKitConversationListVC, didSelectWith conversation: ZIMKitConversation) -> Bool
    
    @objc optional
    func shouldHideSwipeDeleteItem(_ conversationListVC: ZIMKitConversationListVC, didSelectWith conversation: ZIMKitConversation) -> Bool
}
