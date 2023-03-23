//
//  MessageListVC+Options.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/26.
//

import Foundation

extension ZIMKitMessagesListVC: MessageOptionsViewDelegate {
    func showOptionsView(_ cell: MessageCell, _ messageVM: MessageViewModel) {
        let window = UIApplication.key
        window?.embed(optionsView)
        optionsView.show(with: cell.containerView, messageVM: messageVM)
    }

    func hideOptionsView() {
        optionsView.hide()
    }

    func messageOptionsView(_ optionsView: MessageOptionsView, didSelectItemWith type: MessageOptionsView.ContentType) {
        switch type {
        case .copy:
            guard let messageVM = optionsView.messageVM as? TextMessageViewModel else { return }
            UIPasteboard.general.string = messageVM.message.textContent.content
        case .speaker:
            let isSpeakerOff = UserDefaults.standard.bool(forKey: "is_message_speaker_off")
            UserDefaults.standard.set(!isSpeakerOff, forKey: "is_message_speaker_off")
            let icon = isSpeakerOff ? "message_option_speaker" : "message_option_receiver"
            let tip = isSpeakerOff ? L10n("message_speaker_on_tip") : L10n("message_speaker_off_tip")
            HUDHelper.showImage(icon, message: tip)
        case .delete:
            deleteMessages([optionsView.messageVM])
        case .select:
            enableMultiSelect(true, with: optionsView.messageVM)
        }
    }

    func deleteMessages(_ viewModels: [MessageViewModel], completion: ((Bool) -> Void)? = nil) {
        let alert = UIAlertController(title: L10n("message_delete_confirmation_desc"), message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: L10n("conversation_cancel"), style: .cancel) { _ in
            completion?(false)
        }
        let deleteAction = UIAlertAction(title: L10n("conversation_delete"), style: .destructive) { _ in
            completion?(true)
            self.tableView.performBatchUpdates {
                let indexPaths: [IndexPath] = viewModels.compactMap { viewModel in
                    guard let row = self.viewModel.messageViewModels.firstIndex(of: viewModel) else { return nil }
                    return IndexPath(row: row, section: 0)
                }
                self.viewModel.deleteMessages(viewModels)
                self.tableView.deleteRows(at: indexPaths, with: .fade)
            }
            // stop playing audio when delete it.
            if let playingMessageVM = self.audioPlayer.currentMessageVM {
                if viewModels.contains(playingMessageVM) {
                    self.audioPlayer.stop()
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }

    func enableMultiSelect(_ enable: Bool, with messageVM: MessageViewModel? = nil) {
        viewModel.isShowCheckBox = enable
        for VM in viewModel.messageViewModels {
            VM.isSelected = (enable && messageVM === VM) ? true : false
        }
        chatBar.enableMultiSelect(enable)
        setupNav()
        tableView.performBatchUpdates {
            tableView.reloadData()
        }
    }
}

