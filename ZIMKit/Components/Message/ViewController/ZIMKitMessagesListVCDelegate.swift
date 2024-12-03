//
//  ZIMKitMessagesListVCDelegate.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/2/15.
//

import Foundation

@objc public protocol ZIMKitMessagesListVCDelegate: AnyObject {
    @objc optional
    func getMessageListHeaderBar(_ messageListVC: ZIMKitMessagesListVC) -> ZIMKitHeaderBar?
    
    @objc optional
    func getMessageListHeaderCustomerView(_ messageListVC: ZIMKitMessagesListVC) -> UIView?
    
    @objc optional
    func messageListViewWillDisappear()
}
