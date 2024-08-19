//
//  InputConfig.swift
//  Pods
//
//  Created by Kael Ding on 2023/6/1.
//

import Foundation

@available(*, deprecated, message: "This class is deprecated and will be removed in future versions.")
public class InputConfig: NSObject {
    @objc public var showVoiceButton: Bool = true
    @objc public var showEmojiButton: Bool = true
    @objc public var showAddButton: Bool = true
    
    @objc public init(showVoiceButton: Bool, showEmojiButton: Bool, showAddButton: Bool) {
        self.showVoiceButton = showVoiceButton
        self.showEmojiButton = showEmojiButton
        self.showAddButton = showAddButton
    }
    
    @objc public override init() {
        
    }
}
