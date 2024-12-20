//
//  ZIMKitCore.swift
//  Pods-ZegoPlugin
//
//  Created by Kael Ding on 2022/12/8.
//

import Foundation
import ZIM
import ZegoUIKitSignalingPlugin
import ZegoPluginAdapter
class ZIMKitCore: NSObject {
    static let shared = ZIMKitCore()
    
    private(set) var zim: ZIM? = nil
    
    var localUser: ZIMKitUser?
    
    lazy var dataPath: String = {
        let path = NSHomeDirectory() + "/Documents/ZIMKitSDK/" + (localUser?.id ?? "temp")
        return path
    }()
    
    var conversations: [ZIMKitConversation] = []
    var messageList: MessageList = MessageList()
    var groupMemberDict: GroupMemberDict = .init()
    var userDict: ThreadSafeDictionary<String, ZIMKitUser> = .init()
    var isLoadedAllConversations = false
    var isConversationInit = false
    var config : ZIMKitConfig?
    let delegates: NSHashTable<ZIMKitDelegate> = NSHashTable(options: .weakMemory)

    func initWith(appID: UInt32, appSign: String,config:ZIMKitConfig?) {

        ZegoUIKitSignalingPlugin.shared.initWith(appID: appID, appSign: appSign)
        zim = ZIM.shared()
        ZegoUIKitSignalingPlugin.shared.registerZIMEventHandler(self)
        if config != nil {
            self.config = config
            self.config!.appID = appID
            self.config!.appSign = appSign
        }
        
        let IMKitSDKBundle = Bundle(identifier: "org.cocoapods.ZIMKit")
        let IMKitVersion = IMKitSDKBundle?.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        
        let ZegoUIKitSignalingPluginSDKBundle = Bundle(identifier: "org.cocoapods.ZegoUIKitSignalingPlugin")
        let ZegoUIKitSignalingPluginVersion = ZegoUIKitSignalingPluginSDKBundle?.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        
        let initData = ["platform": "iOS" as AnyObject,
                     "platform_version": UIDevice.current.systemVersion as AnyObject,
                     "chat_version": IMKitVersion as AnyObject,
                     "uikit_signalingplugin_version" :ZegoUIKitSignalingPluginVersion as AnyObject]
        
        ReportUtil.sharedInstance().create(withAppID: appID, signOrToken: appSign, commonParams: initData)
        
    }
    
    func unInit() {
        disconnectUser()
        self.zim?.destroy()
        ZegoPluginAdapter.callPlugin?.unInit()
        ReportUtil.sharedInstance().reportEvent("chat/unInit", paramsDict: [:])

    }
    
    func registerZIMKitDelegate(_ delegate: ZIMKitDelegate) {
        delegates.add(delegate)
    }
    
    func clearData() {
        conversations.removeAll()
        messageList.clear()
        groupMemberDict.clear()
        userDict.removeAll()
        
        isLoadedAllConversations = false
        isConversationInit = false
        localUser = nil
    }
}
