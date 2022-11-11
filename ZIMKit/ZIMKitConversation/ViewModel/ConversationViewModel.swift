//
//  ConversationViewModel.swift
//  ZIMKitConversation
//
//  Created by Kael Ding on 2022/8/1.
//

import Foundation
import ZIM

class ConversationViewModel: NSObject {

    /// conversations of current user.
    @Observable var conversations: [ConversationModel] = []

    var isFirstLoadFail = false

    private var isLoadFinish = false
    private var isFirstLoad = true

    override init() {
        super.init()
        ZIMKitManager.shared.addZIMEventHandler(self)
    }
}

extension ConversationViewModel {
    func loadConversations(_ callback: ((ZIMError) -> Void)? = nil) {

        if isLoadFinish {
            return
        }

        let quryConfig = ZIMConversationQueryConfig()
        quryConfig.count = 20
        quryConfig.nextConversation = conversations.last?.toZIMModel()

        print("Start loading conversations..........")

        ZIMKitManager.shared.zim?.queryConversationList(with: quryConfig, callback: { [weak self] zimConversations, error in

            defer {
                self?.isFirstLoad = false
            }

            if error.code != .success {
                if self?.isFirstLoad ?? false {
                    self?.isFirstLoadFail = true
                }
                print("Load conversations failed, code: \(error.code.rawValue), message: \(error.message)")
                guard let callback = callback else { return }
                callback(error)
                return
            }

            self?.isFirstLoadFail = false

            print("Load conversations success, count: \(zimConversations.count)")

            self?.isLoadFinish = zimConversations.count < quryConfig.count

            var conversations = self?.conversations ?? []
            for con in zimConversations {
                let model = ConversationModel(with: con)
                if model.conversationID.count > 0 {
                    conversations.append(model)
                }
            }
            // Sorted by descending order
            self?.conversations = conversations.sorted { $0.orderKey > $1.orderKey }

            guard let callback = callback else { return }
            callback(error)
        })

    }

    func clearConversationUnreadMessageCount(_ conversationID: String, type: ConversationType) {
        let zimType: ZIMConversationType = type == .peer ? .peer : .group
        ZIMKitManager.shared.zim?.clearConversationUnreadMessageCount(conversationID, conversationType: zimType, callback: { _, _, _ in

        })
    }

    func deleteConversation(at index: Int, callback: ((ZIMError) -> Void)?) {
        if index >= conversations.count { return }
        let model = conversations[index]
        conversations.remove(at: index)

        let config = ZIMConversationDeleteConfig()
        config.isAlsoDeleteServerConversation = true
        let zimType: ZIMConversationType = model.type == .peer ? .peer : .group
        ZIMKitManager.shared.zim?.deleteConversation(model.conversationID, conversationType: zimType, config: config, callback: { _, _, error in
            guard let callback = callback else { return }
            callback(error)
        })
    }
}

extension ConversationViewModel: ZIMEventHandler {
    func zim(_ zim: ZIM, conversationChanged conversationChangeInfoList: [ZIMConversationChangeInfo]) {

        self.isFirstLoadFail = false

        var conversations = self.conversations
        for info in conversationChangeInfoList {
            handleConversationChanged(info)
        }
        self.conversations = conversations.sorted { $0.orderKey > $1.orderKey }

        func handleConversationChanged(_ changeInfo: ZIMConversationChangeInfo) {
            if let model = conversations.first(where: { $0.conversationID == changeInfo.conversation.conversationID }) {
                model.update(with: changeInfo.conversation)
            } else {
                conversations.append(ConversationModel(with: changeInfo.conversation))
            }
        }
    }
}
