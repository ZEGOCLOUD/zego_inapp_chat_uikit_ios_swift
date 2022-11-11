//
//  MessageListVC+Options.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/26.
//

import Foundation

extension MessagesListVC: MessageOptionsViewDelegate {
    func showOptionsView(_ cell: MessageCell, _ message: Message) {
        let window = UIApplication.key
        window?.embed(optionsView)
        optionsView.show(with: cell.containerView, message: message)
    }

    func hideOptionsView() {
        optionsView.hide()
    }

    func messageOptionsView(_ optionsView: MessageOptionsView, didSelectItemWith type: MessageOptionsView.ContentType) {
        switch type {
        case .copy:
            guard let message = optionsView.message as? TextMessage else { return }
            UIPasteboard.general.string = message.content
        case .speaker:
            let isSpeakerOff = UserDefaults.standard.bool(forKey: "is_message_speaker_off")
            UserDefaults.standard.set(!isSpeakerOff, forKey: "is_message_speaker_off")
            let icon = isSpeakerOff ? "message_option_speaker" : "message_option_receiver"
            let tip = isSpeakerOff ? L10n("message_speaker_on_tip") : L10n("message_speaker_off_tip")
            HUDHelper.showImage(icon, message: tip)
        case .delete:
            deleteMessages([optionsView.message])
        case .select:
            enableMultiSelect(true, with: optionsView.message)
        }
    }

    func deleteMessages(_ messages: [Message], completion: ((Bool) -> Void)? = nil) {
        let alert = UIAlertController(title: L10n("message_delete_confirmation_desc"), message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: L10n("conversation_cancel"), style: .cancel) { _ in
            completion?(false)
        }
        let deleteAction = UIAlertAction(title: L10n("conversation_delete"), style: .destructive) { _ in
            completion?(true)
            self.tableView.performBatchUpdates {
                let indexPaths: [IndexPath] = messages.compactMap { msg in
                    guard let row = self.viewModel.messages.firstIndex(of: msg) else { return nil }
                    return IndexPath(row: row, section: 0)
                }
                self.viewModel.deleteMessages(messages)
                self.tableView.deleteRows(at: indexPaths, with: .fade)
            }
            // stop playing audio when delete it.
            if let playingMessage = self.audioPlayer.currentMessage {
                if messages.contains(playingMessage) {
                    self.audioPlayer.stop()
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }

    func enableMultiSelect(_ enable: Bool, with message: Message? = nil) {
        viewModel.isShowCheckBox = enable
        for msg in viewModel.messages {
            msg.isSelected = (enable && message === msg) ? true : false
        }
        chatBar.enableMultiSelect(enable)
        setupNav()
        tableView.performBatchUpdates {
            tableView.reloadData()
        }
    }
}

