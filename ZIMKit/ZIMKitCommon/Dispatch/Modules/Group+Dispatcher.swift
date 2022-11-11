//
//  Group+Dispatcher.swift
//  Pods-ZIMKitDemo
//
//  Created by Kael Ding on 2022/7/29.
//

import Foundation

public enum GroupDispatcher: DispatchProtocol {
    case groupDetail(_ groupID: String, groupName: String)
}

public enum GroupActionDispatcher: DispatchProtocol {

}
