//
//  MessageList.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/1/5.
//

import Foundation
import ZIM

// use LRU cache.
class MessageList {
    
    private let cache: LRUCache<String, [ZIMKitMessage]> = .init(capacity: 10)
    
    func add(_ newMessages: [ZIMKitMessage], isNewMessage: Bool = true) {
        if newMessages.count == 0 { return }
        
        let conversationID = newMessages.first!.info.conversationID
        let type = newMessages.first!.info.conversationType
        let key = key(conversationID, type)
        
        // update message
        var messages = [ZIMKitMessage]()
        if let oldMessages = cache.get(key) {
            messages.append(contentsOf: oldMessages)
        }
        if isNewMessage {
            messages.append(contentsOf: newMessages)
        } else {
            messages.insert(contentsOf: newMessages, at: 0)
        }
        messages = messages.sorted { $0.info.orderKey < $1.info.orderKey }
        cache.put(key, messages)
    }
    
    func get(_ conversationID: String, type: ZIMConversationType) -> [ZIMKitMessage] {
        let key = key(conversationID, type)
        return cache.get(key) ?? []
    }
    
    func get(with zimMessage: ZIMMessage) -> ZIMKitMessage {
        let messages = get(zimMessage.conversationID, type: zimMessage.conversationType)
        let kitMessage = messages.first(where: { $0.info.localMessageID == zimMessage.localMessageID })
        return kitMessage ?? ZIMKitMessage(with: zimMessage)
    }
        
    func delete(_ messages: [ZIMKitMessage]) {
        if messages.count == 0 { return }
        
        let conversationID = messages.first!.info.conversationID
        let type = messages.first!.info.conversationType
        let key = key(conversationID, type)
        
        guard let allMessages = cache.get(key) else { return }
        let messageIDs = messages.compactMap({ $0.info.localMessageID })
        let newMessages = allMessages.filter({ !messageIDs.contains($0.info.localMessageID) })
        
        cache.put(key, newMessages)
    }
    
    func delete(_ conversationID: String, type: ZIMConversationType) {
        let key = key(conversationID, type)
        cache.delete(key)
    }
    
    func clear() {
        cache.clear()
    }
    
    // MARK: - Private
    private func key(_ conversationID: String, _ type: ZIMConversationType) -> String {
        var key = conversationID + "_zego_"
        switch type {
        case .peer:
            key += "peer"
        case .group:
            key += "group"
        case .room:
            key += "room"
        case .unknown:
            break
        @unknown default:
            break
        }
        return key
    }
}
