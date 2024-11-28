//
//  ZIMKit.swift
//
//  Created by Kael Ding on 2022/12/5.
//

import Foundation
import ZegoPluginAdapter


@objc public enum ZIMKitMessageOperationName: Int {
    case copy
    case reply
    case forward
    case revoke
    case reaction
    case delete
}

@objc public enum ZIMKitMenuBarButtonName: Int {
    case audio // 发送语音
    case emoji // 发送表情
    case picture // 发送图片
    case takePhoto // 拍照
    case voiceCall // 发起音频通话
    case videoCall // 发起视频通话
    case file // 发送文件
    case expand // 更多按钮
}

public class ZIMKit: NSObject {
    var imKitConfig: ZIMKitConfig = ZIMKitCore.shared.config ?? ZIMKitConfig()
  
    @objc public static func initWith(appID: UInt32, appSign: String) {
        ZIMKitCore.shared.initWith(appID: appID, appSign: appSign, config: nil)
    }
    
    @objc public static func initWith(appID: UInt32, appSign: String,config:ZIMKitConfig?) {
        ZIMKitCore.shared.initWith(appID: appID, appSign: appSign,config: config)
    }
    
    @objc public static func registerZIMKitDelegate(_ delegate: ZIMKitDelegate) {
        ZIMKitCore.shared.registerZIMKitDelegate(delegate)
    }
  
    @objc public static func registerCallKitDelegate(_ delegate: AnyObject) {
      ZegoPluginAdapter.callPlugin?.registerCallKitDelegate(delegate: delegate)
    }
}

@objc public class ZIMKitConfig: NSObject {
    @objc public var callPluginConfig: ZegoCallPluginConfig?
    public var bottomConfig = ZIMKitBottomConfig()
    public var conversationConfig = ZIMKitConversationConfig()
    public var messageConfig = ZIMKitMessageConfig()
  
    public var appID: UInt32?
    public var appSign :String = ""
  
    @objc public var navigationBarColor: UIColor = UIColor.white
    @objc public var inputPlaceholder:NSAttributedString =  NSAttributedString(string: L10n("enter_new_message"), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0x8E9093), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])

}

public class ZIMKitBottomConfig {
    public var smallButtons: [ZIMKitMenuBarButtonName] = [.audio, .emoji, .picture, .expand] {
      didSet {
           if smallButtons.isEmpty {
               smallButtons = [.audio,.emoji,.picture,.expand]
           }
       }
    }
    public let maxCount: Int = 4
    public var expandButtons: [ZIMKitMenuBarButtonName] = [.takePhoto, .file]
    public var emojis: [String] = ["😀", "😃", "😄", "😁", "😆", "😅", "😂",
                                   "😇", "😉", "😊", "😋", "😌", "😍", "😘",
                                   "😗", "😙", "😚", "😜", "😝", "😛", "😎",
                                   "😏", "😶", "😐", "😑", "😒", "😳", "😞",
                                   "😟", "😤", "😠", "😡", "😔", "😕", "😬",
                                   "😣", "😖", "😫", "😩", "😪", "😮", "😱",
                                   "😨", "😰", "😥", "😓", "😯", "😦", "😧",
                                   "😢", "😭", "😵", "😲", "😷", "😴", "💤",
                                   "😈", "👿", "👹", "👺", "💩", "👻", "💀",
                                   "👽", "🎃", "😺", "😸", "😹", "😻", "😼",
                                   "😽", "🙀", "😿", "😾", "👐", "🙌", "👏",
                                   "🙏", "👍", "👎", "👊", "✊", "👌", "👈",
                                   "👉", "👆", "👇", "✋", "👋", "💪", "💅",
                                   "👄", "👅", "👂", "👃", "👀", "👶", "👧",
                                   "👦", "👩", "👨", "👱", "👵", "👴", "👲",
                                   "👳‍", "👼", "👸", "👰", "🙇", "💁", "🙅‍",
                                   "🙆", "🙋", "🙎", "🙍", "💇", "💆", "💃",
                                   "👫", "👭", "👬", "💛", "💚", "💙", "💜",
                                   "💔", "💕", "💞", "💓", "💗", "💖", "💘",
                                   "💝", "💟"]
}

public class ZIMKitConversationConfig: NSObject {
  
}

public class ZIMKitMessageConfig: NSObject {
  public var textMessageConfig = ZIMKitTextMessageConfig()
  public var audioMessageConfig = ZIMKitAudioMessageConfig()
  public var videoMessageConfig = ZIMKitVideoMessageConfig()
  public var imageMessageConfig = ZIMKitImageMessageConfig()
  public var fileMessageConfig = ZIMKitFileMessageConfig()
  
  // 默认为空数组，则使用 ZIMKit 内部，否则使用客户提供的
  public var messageReactions: [String] = []
}

public class ZIMKitTextMessageConfig {
    public var operations: [ZIMKitMessageOperationName] = [.copy, .reply, .forward, .delete, .revoke, .reaction]
}

public class ZIMKitAudioMessageConfig {
    public var operations: [ZIMKitMessageOperationName] = [.reply, .forward, .revoke, .delete, .reaction]
}

public class ZIMKitVideoMessageConfig {
    public var operations: [ZIMKitMessageOperationName] = [.reply, .forward, .revoke, .delete, .reaction]
}

public class ZIMKitImageMessageConfig {
    public var operations: [ZIMKitMessageOperationName] = [.reply, .forward, .revoke, .delete, .reaction]
}

public class ZIMKitFileMessageConfig {
    public var operations: [ZIMKitMessageOperationName] = [.reply, .forward, .revoke, .delete, .reaction]
}
