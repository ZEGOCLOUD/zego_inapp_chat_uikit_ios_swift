//
//  InputConfig.swift
//  Pods
//
//  Created by Kael Ding on 2023/6/1.
//

import Foundation

public class InputConfig {
    public var showVoiceButton: Bool = true
    public var showEmojiButton: Bool = true
    public var showAddButton: Bool = true
    
    public init(showVoiceButton: Bool, showEmojiButton: Bool, showAddButton: Bool) {
        self.showVoiceButton = showVoiceButton
        self.showEmojiButton = showEmojiButton
        self.showAddButton = showAddButton
    }
    
    public init() {
        
    }
}
