//
//  ZIMKit.swift
//
//  Created by Kael Ding on 2022/12/5.
//

import Foundation
import ZegoPluginAdapter

public class ZIMKit: NSObject {
    @objc public static func initWith(appID: UInt32, appSign: String) {
        ZIMKitCore.shared.initWith(appID: appID, appSign: appSign, config: nil)
    }
    
    @objc public static func initWith(appID: UInt32, appSign: String,config:ZIMKitConfig?) {
        ZIMKitCore.shared.initWith(appID: appID, appSign: appSign,config: config)
    }
    
    @objc public static func registerZIMKitDelegate(_ delegate: ZIMKitDelegate) {
        ZIMKitCore.shared.registerZIMKitDelegate(delegate)
    }
}

public class ZIMKitConfig: NSObject {
    public var resourceID: String = ""
}
