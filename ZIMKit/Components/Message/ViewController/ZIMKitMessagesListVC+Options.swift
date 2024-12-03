//
//  MessageListVC+Options.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/26.
//

import Foundation
import ZIM

extension ZIMKitMessagesListVC: MessageOptionsViewDelegate {
    
    func showOptionsView(_ cell: MessageCell, _ messageVM: MessageViewModel) {
        if messageVM.message.type == .unknown {
            return
        }
        let window = UIApplication.key
        optionsView = MessageOptionsView(frame: view.bounds).withoutAutoresizingMaskConstraints
        optionsView!.delegate = self
        
        window?.embed(optionsView!)
        optionsView!.show(with: cell.containerView, messageVM: messageVM)
    }
    
    func hideOptionsView() {
        optionsView?.hide()
        optionsView = nil
    }
    
    func messageOptionsView(_ optionsView: MessageOptionsView, didSelectItemWith type: MessageOptionsView.ContentType) {
        switch type {
        case .copy:
           
            if optionsView.messageVM is TextMessageViewModel || (optionsView.messageVM is ReplyMessageViewModel && optionsView.messageVM.message.type == .text) {
                UIPasteboard.general.string = optionsView.messageVM.message.textContent.content
                HUDHelper.showMessage(L10n("message_copy_success"))
            }
            
        case .speaker:
            let isSpeakerOff = UserDefaults.standard.bool(forKey: "is_message_speaker_off")
            UserDefaults.standard.set(!isSpeakerOff, forKey: "is_message_speaker_off")
            let icon = isSpeakerOff ? "message_option_speaker" : "message_option_receiver"
            let tip = isSpeakerOff ? L10n("message_speaker_on_tip") : L10n("message_speaker_off_tip")
            HUDHelper.showImage(icon, message: tip)
        case .delete:
            deleteMessages([optionsView.messageVM])
        case .multipleChoice:
            enableMultiSelect(true, with: optionsView.messageVM)
        case .reply:
            //回复
            replyMessage(optionsView: optionsView)
        case .forward:
            //转发
            forwardMessage(messages: [optionsView.messageVM])
        case .revoke:
            // 撤回
            revokeMessage(view: optionsView)
        case .reaction:
            print("---")
            
        }
    }
    
    func replyMessage(optionsView: MessageOptionsView) {
        let fromUserName:String = optionsView.messageVM.message.info.senderUserName ?? ""
        var content:String = optionsView.messageVM.message.getShortString()
        if optionsView.messageVM.message.type == .combine {
            guard let messageVM = optionsView.messageVM as? CombineMessageViewModel else { return }
            content = messageVM.combineTitle
        }
        chatBar.replyMessage(fromUserName: fromUserName, content: content,originMessage: optionsView.messageVM.message)
    }
    
    func messageOptionsViewEmojiMessage(emoji: String, optionsView: MessageOptionsView) {
        sendEmojiCheck(emoji: emoji, messageVM: optionsView.messageVM)
        optionsView.hide()
        
    }
    
    func sendEmojiCheck(emoji: String, messageVM: MessageViewModel) {
        let containCurrentEmoji = judgeCurrentEmojiAlreadyExists(emoji: emoji, reactions: messageVM.message.reactions)
        if containCurrentEmoji == true {
            deleteMessageReaction(emoji: emoji, message: messageVM.message)
        } else {
            addMessageReaction(emoji: emoji, message: messageVM.message)
        }
    }
    
    func addMessageReaction(emoji: String,message: ZIMKitMessage ) {
        ZIMKit.addMessageReactionByMessage(for: message, reactionType: emoji) { [weak self] reaction, error in
            if error.code.rawValue != 0 {
                print("addMessageReactionByMessage errorCode: \(error.code) msg: \(error.message)")
//                HUDHelper.showErrorMessageIfNeeded(error.code.rawValue, defaultMessage: error.code.rawValue == 6000602 ? L10n("history_message_no_support_reaction") : L10n("reaction_reply_failed"))
            } else {
                self?.viewModel.onMessageReactionsChanged([reaction])
            }
        }
    }
    
    func deleteMessageReaction(emoji: String,message: ZIMKitMessage ) {
        ZIMKit.deleteMessageReaction(for: message, reactionType: emoji) { [weak self] reaction, error in
            print("deleteMessageReaction errorCode: \(error.code) msg: \(error.message)")
            if error.code.rawValue == 0 {
                self?.viewModel.onMessageReactionsChanged([reaction])
            }
        }
    }
    
    func deleteMessages(_ viewModels: [MessageViewModel], completion: ((Bool) -> Void)? = nil) {
        
        let popView: ZIMKitAlertView = ZIMKitAlertView.init(title: L10n("delete_message_title"), detail: L10n("message_delete_confirmation_desc_tip"), buttonCount: [L10n("conversation_cancel"),L10n("common_sure")]) {
            
        } sureBlock: { [weak self] in
            self?.deleteIMMessage(viewModels: viewModels)
            completion?(true)
        }
        popView.showView()
    }
    
    private func deleteIMMessage(viewModels:[MessageViewModel]) {
        self.tableView.performBatchUpdates { [weak self] in
            let indexPaths: [IndexPath] = viewModels.compactMap { viewModel in
                guard let row = self?.viewModel.messageViewModels.firstIndex(of: viewModel) else { return nil }
                return IndexPath(row: row, section: 0)
            }
            self?.viewModel.deleteMessages(viewModels)
            self?.tableView.beginUpdates()
            self?.tableView.deleteRows(at: indexPaths, with: .fade)
            self?.tableView.endUpdates()
        }
        // stop playing audio when delete it.
        if let playingMessageVM = self.audioPlayer.currentMessageVM {
            if viewModels.contains(playingMessageVM) {
                self.audioPlayer.stop()
            }
        }
    }
    
    func forwardMessage(messages:[MessageViewModel]) {
        guard let unwrappedArray = messages as? [MessageViewModel]?,!unwrappedArray!.isEmpty else { return }
        let chatListVC = ZIMKitRecentChatListVC()
        chatListVC.forwardType = .forward
        chatListVC.conversationType = conversationType
        chatListVC.combineConversationName = messages.first!.message.getShortString()
        chatListVC.conversationList = messages.compactMap{ $0.message }
        self.navigationController?.pushViewController(chatListVC, animated: true)
    }
    
    func revokeMessage(view: MessageOptionsView) {
        
        let popView: ZIMKitAlertView = ZIMKitAlertView.init(title: L10n("revoke_message_title"), detail: L10n("revoke_message_des"), buttonCount: [L10n("conversation_cancel"),L10n("common_sure")]) {
            
        } sureBlock: { [weak self] in
            self?.viewModel.revokeMessage(view.messageVM) { error  in
                
            }
        }
        popView.showView()
    }
    
    func enableMultiSelect(_ enable: Bool, with messageVM: MessageViewModel? = nil) {
        viewModel.isShowCheckBox = enable
        for VM in viewModel.messageViewModels {
            VM.isSelected = (enable && messageVM === VM) ? true : false
        }
        chatBar.enableMultiSelect(enable)
        setupNav()
        tableView.reloadData()
    }
    
    private func judgeCurrentEmojiAlreadyExists(emoji: String,reactions: [ZIMMessageReaction]) -> Bool {
        var containEmoji = false
        for (_,reaction) in reactions.enumerated() {
            if reaction.reactionType == emoji {
                for (_,userInfo) in reaction.userList.enumerated() {
                    if userInfo.userID == ZIMKit.localUser?.id {
                        containEmoji = true
                        break
                    }
                }
            }
            if containEmoji {
                break
            }
        }
        return containEmoji
    }
}

