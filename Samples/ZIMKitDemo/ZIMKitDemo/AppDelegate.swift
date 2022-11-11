//
//  AppDelegate.swift
//  ZIMKitDemo
//
//  Created by Kael Ding on 2022/7/29.
//

import UIKit
import ZIM
import ZIMKit
#if !DEBUG
import Bugly
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        configBugly()
        registerNotification()

        // create the ZIM instance
        ZIMKitManager.shared.initWith(appID: KeyCenter.appID(), appSign: KeyCenter.appSign())
        window = UIWindow(frame: UIScreen.main.bounds)

        let loginVC = LoginViewController()
        window?.rootViewController = loginVC
        window?.makeKeyAndVisible()

        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


    func registerNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if error != nil {
                print("request authorization failed.")
                return
            }

            center.delegate = self
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func configBugly() {
        #if !DEBUG
        let config = BuglyConfig()
        config.blockMonitorEnable = true
        Bugly.setUserValue(ZIM.getVersion(), forKey: "ZIM_Version")
        Bugly.start(withAppId: "9c20582e3b", config: config)
        #endif
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    //    @available(iOS 13.0.0, *)
    //    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
    //
    //        // local notifications
    //        if response.notification.request.identifier == LocalNotificationRequestId {
    //            handleLocalNotification(response)
    //        }
    //
    //        else {
    //
    //        }
    //    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // local notifications
        if response.notification.request.identifier == LocalNotificationRequestId {
            handleLocalNotification(response)
        }

        else {

        }
        completionHandler()
    }

    private func handleLocalNotification(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        if let conversationID = userInfo["conversationID"] as? String,
           let typeValue = userInfo["conversationType"] as? UInt,
           let conversationType: ConversationType = typeValue == 0 ? .peer : .group {
            let topVc = UIApplication.topViewController()
            if topVc is ConversationListVC {
                Dispatcher.open(MessagesDispatcher.messagesList(conversationID, conversationType, ""))
            }
        }
    }
}

