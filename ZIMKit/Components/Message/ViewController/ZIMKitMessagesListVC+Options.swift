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
//        case .reply:
//            //回复
//            replayMessage()
//        case .forward:
//            //转发
//            forwardMessage()
//        case .revoke:
//            // 撤回
//          revokeMessage(view: optionsView)
        }
      
    }

  
    func messageOptionsViewEmojiMessage(emoji: String) {
      chatBar(self.chatBar, didSendText: emoji)
    }
  
    func deleteMessages(_ viewModels: [MessageViewModel], completion: ((Bool) -> Void)? = nil) {


      let popView: ZIMKitAlertView = ZIMKitAlertView.init(title: L10n("delete_message_title"), detail: L10n("message_delete_confirmation_desc"), buttonCount: [L10n("conversation_cancel"),L10n("common_sure")]) {
        
      } sureBlock: { [self] in
        self.deleteIMMessage(viewModels: viewModels)
      }
      popView.showView()
    }
  
    private func deleteIMMessage(viewModels:[MessageViewModel]) {
      self.tableView.performBatchUpdates { [self] in
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
  
    func forwardMessage() {
      
    }
    
    func replayMessage() {
      
    }
  
  
    
  func revokeMessage(view:MessageOptionsView) {
    let viewModels:[MessageViewModel] = [view.messageVM]
      ZIMKit.revokeMessage(view.messageVM.message) { error in
        if error.code.rawValue == 0 {
          self.tableView.performBatchUpdates {
              let indexPaths: [IndexPath] = viewModels.compactMap { viewModel in
                  guard let row = self.viewModel.messageViewModels.firstIndex(of: viewModel) else { return nil }
                  return IndexPath(row: row, section: 0)
              }
              self.viewModel.deleteMessages(viewModels)
              self.tableView.deleteRows(at: indexPaths, with: .fade)
          }
        }
        print("revokeMessage  code = \(error.code)")
      }
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

