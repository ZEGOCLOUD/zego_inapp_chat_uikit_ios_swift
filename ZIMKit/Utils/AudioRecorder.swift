//
//  AudioRecorder.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/5.
//

import Foundation
import AVFoundation

public protocol AudioRecorderDelegate: AnyObject {
    func recorder(_ recorder: AudioRecorder, didRecordWith timeInterval: TimeInterval)
    func recorderBeginInterruption(_ recorder: AudioRecorder)
}

public class AudioRecorder: NSObject, AVAudioRecorderDelegate {

    private var recorder: AVAudioRecorder?
    private var recordTimer: Timer?
    private var recordStartTime: Date?
    private var isTriggerFeedbackGenerator: Bool = false

    public weak var delegate: AudioRecorderDelegate?

    public var path: String? {
        recorder?.url.path
    }

    public var timeInterval: TimeInterval {
        guard let date = recordStartTime else { return 0 }
        let interval = Date().timeIntervalSince(date)
        return interval
    }

    public var isRecording: Bool {
        recorder?.isRecording == true
    }

    public func startRecord() {

        isTriggerFeedbackGenerator = false
        recordStartTime = Date()

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord)
        try? session.setActive(true)
        if #available(iOS 13.0, *) {
            try? session.setAllowHapticsAndSystemSoundsDuringRecording(true)
        }

        func generateFileName() -> String {
            return String(format: "%d%0.0f", UInt32.random(in: 1000...9999), Date().timeIntervalSince1970)
        }

        let path = NSTemporaryDirectory()
        let filePath = path + "\(generateFileName()).m4a"

        let setting: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
            AVLinearPCMBitDepthKey: 16,
            AVSampleRateKey: 8000.0
        ]
        recorder = try? AVAudioRecorder(url: URL(string: filePath)!, settings: setting)
        recorder?.delegate = self
        recorder?.isMeteringEnabled = true
        recorder?.prepareToRecord()
        recorder?.record()
        recorder?.updateMeters()
        recordTimer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(recordTrick(_:)),
            userInfo: nil, repeats: true)
    }

    public func stopRecord() {
        if recordTimer != nil {
            recordTimer?.invalidate()
            recordTimer = nil
        }
        if recorder?.isRecording == true {
            recorder?.stop()
        }
    }

    public func cancelRecord() {
        if let path = recorder?.url.path, FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
        stopRecord()
    }

    @objc private func recordTrick(_ timer: Timer) {
        recorder?.updateMeters()

        let interval = timeInterval
        delegate?.recorder(self, didRecordWith: interval)

        if interval >= 50.0 && !isTriggerFeedbackGenerator {
            isTriggerFeedbackGenerator = true
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred()
        }
    }

    public func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        delegate?.recorderBeginInterruption(self)
    }

    public func audioRecorderEndInterruption(_ recorder: AVAudioRecorder, withOptions flags: Int) {

    }
}
