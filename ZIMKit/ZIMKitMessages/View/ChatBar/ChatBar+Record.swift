//
//  ChatBar+Record.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/5.
//

import Foundation
import AVFAudio

extension ChatBar: AudioRecorderDelegate {

    @objc func recordButton(started sender: UIButton) {
        sender.backgroundColor = .zim_backgroundGray4
        let permission = AVAudioSession.sharedInstance().recordPermission
        if permission == .denied || permission == .undetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if !granted {
                    DispatchQueue.main.async {
                        guard let vc = UIApplication.topViewController() else { return }
                        AuthorizedCheck.showMicrophoneUnauthorizedAlert(vc)
                    }
                }
            }
            sender.cancelTracking(with: nil)
            return
        }
        if permission != .granted { return }
        recorder.startRecord()
        recorderView.show()
        recorderView.setBottomText(L10n("message_audio_record_tip1"))
        delegate?.chatBar(self, didStartToRecord: recorder)
    }

    @objc func recordButton(ended sender: UIButton) {
        sender.backgroundColor = .zim_backgroundWhite
        sender.setTitle(L10n("message_audio_record_normal"), for: .normal)
        recorderView.hide()

        // cancelTracking will trigger this method,
        // so should judge the recording status
        if !recorder.isRecording { return }

        let interval = recorder.timeInterval

        if interval < 1 {
            recorder.cancelRecord()
            HUDHelper.showImage("message_tip_icon", message: L10n("message_audio_record_too_short"))
            return
        } else if interval > 60 {
            if recorder.isRecording { return }
            recorder.cancelRecord()
        } else {
            guard let path = recorder.path else { return }
            let duration = UInt32(round(recorder.timeInterval))
            recorder.stopRecord()
            delegate?.chatBar(self, didSendAudioWith: path, duration: duration)
        }
    }

    @objc func recordButton(canceled sender: UIButton) {
        sender.backgroundColor = .zim_backgroundWhite
        sender.setTitle(L10n("message_audio_record_normal"), for: .normal)
        recorderView.hide()
        if !recorder.isRecording { return }
        recorder.cancelRecord()
    }

    @objc func recordButton(dragEnter sender: UIButton) {
        sender.backgroundColor = .zim_backgroundGray4
        recorderView.setBottomText(L10n("message_audio_record_tip1"))
        recorderView.setAnimationStatus(status: .normal)
    }

    @objc func recordButton(dragExit sender: UIButton) {
        sender.backgroundColor = .zim_backgroundGray4
        sender.setTitle(L10n("message_audio_record_release_to_cancel"), for: .normal)
        recorderView.setBottomText(L10n("message_audio_record_tip2"))
        recorderView.setAnimationStatus(status: .toBeCancelled)
    }

    func recorder(_ recorder: AudioRecorder, didRecordWith timeInterval: TimeInterval) {

        if timeInterval > 50 && timeInterval < 60 {
            recorderView.setRemainTimeSeconds(Int(60-timeInterval)+1)
        }
        else if timeInterval >= 60 {
            endRecord()
        }
    }

    func recorderBeginInterruption(_ recorder: AudioRecorder) {
        recordButton.cancelTracking(with: nil)
    }

    func cancelRecord() {
        if !recorder.isRecording { return }
        recordButton.cancelTracking(with: nil)
    }

    func endRecord() {
        if !recorder.isRecording { return }
        guard let path = recorder.path else { return }
        var duration = UInt32(round(recorder.timeInterval))
        if duration > 60 { duration = 60 }
        if duration < 1 { return }
        recorder.stopRecord()
        recordButton.cancelTracking(with: nil)
        delegate?.chatBar(self, didSendAudioWith: path, duration: duration)
    }
}
