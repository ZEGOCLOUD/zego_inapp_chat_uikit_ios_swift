//
//  MessageAudioPlayer.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/6.
//

import Foundation
import AVFAudio
import AVFoundation

class MessageAudioPlayer: NSObject, AVAudioPlayerDelegate {
    private(set) var currentMessageVM: MediaMessageViewModel?
    private var player: AVAudioPlayer?
    weak var tableView: UITableView?

    convenience init(with tableView: UITableView) {
        self.init()
        self.tableView = tableView
    }

    func play(with messageVM: MediaMessageViewModel) -> Bool {

        stopAudioAnimation()

        if messageVM === currentMessageVM {
            if player?.isPlaying == true {
                player?.stop()
                player = nil
                return true
            }
        }

        player = nil
        currentMessageVM = messageVM

        var isHeadphones = false
        for desc in AVAudioSession.sharedInstance().currentRoute.outputs
        where desc.portType == .bluetoothA2DP ||
            desc.portType == .headphones ||
            desc.portType == .bluetoothLE ||
            desc.portType == .bluetoothHFP {
            isHeadphones = true
            break
        }

        let isSpeakerOff = UserDefaults.standard.bool(forKey: "is_message_speaker_off")
        var options: AVAudioSession.CategoryOptions = []
        if !isSpeakerOff {
            options.insert(.defaultToSpeaker)
        }
        try? AVAudioSession.sharedInstance().setCategory(
            isHeadphones ? .playback : .playAndRecord,
            options: options)
        do {
            if isSpeakerOff {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
            }
            let data = try Data(contentsOf: URL(fileURLWithPath: messageVM.message.fileLocalPath))
            player = try AVAudioPlayer(data: data)
        } catch let error {
            print(error)
            return false
        }

        guard let player = player else { return false }

        player.delegate = self
        if player.prepareToPlay() {
            startAudioAnimation()
            return player.play()
        }
        return false
    }

    func stop() {
        stopAudioAnimation()
        player?.stop()
        player = nil
    }

    private func startAudioAnimation() {
        currentMessageVM?.isPlayingAudio = true
        guard let cells = tableView?.visibleCells else { return }
        for _ in cells {

            for cell in cells {
                if let audioCell = cell as? AudioMessageCell {
                    if audioCell.messageVM === currentMessageVM {
                        audioCell.startAudioAnimation()
                        currentMessageVM?.isPlayingAudio = true
                    }
                } else if let replyCell = cell as? ReplyMessageCell {
                    if let view = replyCell.audioMediaView as? MediaAudioReplyView? {
                        view?.startAudioAnimation()
                        currentMessageVM?.isPlayingAudio = true
                    }
                }
            }
        }
    }

    private func stopAudioAnimation() {
        currentMessageVM?.isPlayingAudio = false
        guard let cells = tableView?.visibleCells else { return }
        for cell in cells {
            if let audioCell = cell as? AudioMessageCell {
                audioCell.stopAudioAnimation()
            } else if let replyCell = cell as? ReplyMessageCell {
                if let view = replyCell.audioMediaView as? MediaAudioReplyView? {
                    view?.stopAudioAnimation()
                }
            }
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAudioAnimation()
    }
}
