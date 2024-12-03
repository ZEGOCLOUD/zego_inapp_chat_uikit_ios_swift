//
//  ZIMKitSendVoiceMessageView.swift
//  ZIMKit
//
//  Created by zego on 2024/7/31.
//

import UIKit
import Foundation
import AVFAudio

protocol SendVoiceMessageDelegate: AnyObject {
    func chatBar(didStartToRecord recorder: AudioRecorder)
    func chatBar(didCancelRecord recorder: AudioRecorder)
    func chatBar(didSendAudioWith path: String, duration: UInt32)
    
}
class ZIMKitSendVoiceMessageView: UIView {
    
    lazy var recorder: AudioRecorder = AudioRecorder()
    let animatedView = AnimatedImageView().withoutAutoresizingMaskConstraints
    lazy var titleLB: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = UIColor(hex: 0x8E9093)
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.text = L10n("message_audio_record_normal")
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = UIColor(hex: 0x8E9093)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    lazy var recordingView: UIView = {
        let view: UIView = UIView().withoutAutoresizingMaskConstraints
        view.isHidden = true
        return view
    }()
    
    lazy var dragExitView: UIView = {
        let view: UIView = UIView().withoutAutoresizingMaskConstraints
        view.isHidden = true
        return view
    }()
    
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(hex: 0x5E95FF).cgColor, UIColor(hex: 0x3478FC).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.frame = CGRectMake(3, 3, 103, 103)
        let maskLayer = CAShapeLayer()
        let path1 = UIBezierPath(ovalIn: CGRectMake(0, 0, 100, 100))
        maskLayer.path = path1.cgPath
        gradientLayer.mask = maskLayer
        return gradientLayer
    }()
    
    lazy var sendVoiceButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "btn_send_voice_image"), for: .normal)
        button.setImage(loadImageSafely(with: "btn_wave"), for: .highlighted)
        
        button.clipsToBounds = true
        button.layer.cornerRadius = 53.0
        button.layer.borderColor = UIColor(hex: 0x3478FC, a: 0.2).cgColor
        button.layer.borderWidth = 3
        
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        button.bringSubviewToFront(button.imageView!)
        
        button.addTarget(
            self, action: #selector(started(_:)),
            for: .touchDown)
        button.addTarget(
            self, action: #selector(ended(_:)),
            for: .touchUpInside)
        button.addTarget(
            self, action: #selector(canceled(_:)),
            for: [.touchUpOutside, .touchCancel])
        button.addTarget(
            self, action: #selector(dragEnter(_:)),
            for: .touchDragEnter)
        button.addTarget(
            self, action: #selector(dragExit(_:)),
            for: .touchDragExit)
        
        return button
    }()
    
    weak var delegate: SendVoiceMessageDelegate?
    var topConstraint: NSLayoutConstraint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .zim_backgroundGray2
        setupSubViews()
        setupLayoutConstraint()
        recorder.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubViews() {
        addSubview(titleLB)
        addSubview(sendVoiceButton)
        addSubview(recordingView)
        addSubview(dragExitView)
        addRecordingSubviews()
        addDragExitSubviews()
    }
    
    func setupLayoutConstraint() {
        
        NSLayoutConstraint.activate([
            titleLB.centerXAnchor.pin(equalTo: centerXAnchor, constant: 0),
            titleLB.heightAnchor.pin(equalToConstant: 22),
            titleLB.leadingAnchor.pin(equalTo: leadingAnchor, constant: 0),
            titleLB.trailingAnchor.pin(equalTo: trailingAnchor, constant: 0),
        ])
        topConstraint = titleLB.topAnchor.pin(equalTo: topAnchor, constant: 32)
        topConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            sendVoiceButton.topAnchor.pin(equalTo: titleLB.bottomAnchor, constant: 15),
            sendVoiceButton.widthAnchor.pin(equalToConstant: 106.0),
            sendVoiceButton.heightAnchor.pin(equalToConstant: 106.0),
            sendVoiceButton.centerXAnchor.pin(equalTo: centerXAnchor, constant: 0),
        ])
        
        NSLayoutConstraint.activate([
            recordingView.topAnchor.pin(equalTo: topAnchor, constant: 0),
            recordingView.leadingAnchor.pin(equalTo: leadingAnchor, constant: 0),
            recordingView.trailingAnchor.pin(equalTo: trailingAnchor, constant: 0),
            recordingView.heightAnchor.pin(equalToConstant: 135.0)
        ])
        
        NSLayoutConstraint.activate([
            dragExitView.topAnchor.pin(equalTo: topAnchor, constant: 0),
            dragExitView.leadingAnchor.pin(equalTo: leadingAnchor, constant: 0),
            dragExitView.trailingAnchor.pin(equalTo: trailingAnchor, constant: 0),
            dragExitView.heightAnchor.pin(equalToConstant: 135.0)
        ])
    }
    
    //MARK: SubViews
    func addRecordingSubviews () {
        let closeImage: UIImageView = UIImageView(image: loadImageSafely(with: "btn_voice_send_cancel_img")).withoutAutoresizingMaskConstraints
        closeImage.backgroundColor = .zim_backgroundWhite
        closeImage.clipsToBounds = true
        closeImage.layer.cornerRadius = 12
        
        // 创建 DotView 实例
        let dotView = DotView().withoutAutoresizingMaskConstraints
        dotView.backgroundColor = .zim_backgroundGray2
        // 添加到视图层级
        recordingView.addSubview(dotView)
        
        recordingView.addSubview(timeLabel)
        recordingView.addSubview(closeImage)
        recordingView.addSubview(animatedView)
        let path = Bundle.ZIMKit.path(
            forResource: "sound-level-blue-unscreen",
            ofType: "gif")
        animatedView.animated(withPath: path!)
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.pin(equalTo: topAnchor, constant: 20),
            timeLabel.leadingAnchor.pin(equalTo: leadingAnchor, constant: 0),
            timeLabel.trailingAnchor.pin(equalTo: trailingAnchor, constant: 0),
            timeLabel.heightAnchor.pin(equalToConstant: 20.0)
        ])
        
        NSLayoutConstraint.activate([
            closeImage.bottomAnchor.pin(equalTo: recordingView.bottomAnchor, constant: -20),
            closeImage.widthAnchor.pin(equalToConstant: 24.0),
            closeImage.heightAnchor.pin(equalToConstant: 24.0),
            closeImage.centerXAnchor.pin(equalTo: recordingView.centerXAnchor, constant: 0),
        ])
        
        NSLayoutConstraint.activate([
            animatedView.bottomAnchor.pin(equalTo: closeImage.topAnchor, constant: -30),
            animatedView.leadingAnchor.pin(equalTo: recordingView.leadingAnchor, constant: 110),
            animatedView.trailingAnchor.pin(equalTo: recordingView.trailingAnchor, constant: -110),
            animatedView.heightAnchor.pin(equalToConstant: 8.0),
        ])
        
        NSLayoutConstraint.activate([
            dotView.centerYAnchor.pin(equalTo: animatedView.centerYAnchor),
            dotView.leadingAnchor.pin(equalTo: leadingAnchor, constant: 15),
            dotView.trailingAnchor.pin(equalTo: trailingAnchor, constant: -15),
            dotView.heightAnchor.pin(equalToConstant: 8.0)
        ])
    }
    
    func addDragExitSubviews() {
        let cancelImage: UIImageView = UIImageView().withoutAutoresizingMaskConstraints
        let image:UIImage = loadImageSafely(with: "icon_cancel_l")
        cancelImage.backgroundColor = UIColor(hex: 0xFF3C48)
        cancelImage.clipsToBounds = true
        cancelImage.layer.cornerRadius = 35
        cancelImage.contentMode = .center
        let newSize = CGSize(width: 48, height: 48)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin:.zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        cancelImage.image = scaledImage
        
        
        let titleLB = UILabel().withoutAutoresizingMaskConstraints
        titleLB.text = L10n("message_audio_cancel_tip")
        titleLB.textColor = UIColor(hex: 0xFF3C48)
        titleLB.font = UIFont.systemFont(ofSize: 15)
        titleLB.textAlignment = .center
        
        dragExitView.addSubview(titleLB)
        dragExitView.addSubview(cancelImage)
        
        NSLayoutConstraint.activate([
            titleLB.topAnchor.pin(equalTo: topAnchor, constant: 30),
            titleLB.heightAnchor.pin(equalToConstant: 22),
            titleLB.widthAnchor.pin(equalTo: widthAnchor),
            titleLB.centerXAnchor.pin(equalTo: dragExitView.centerXAnchor, constant: 0),
        ])
        
        NSLayoutConstraint.activate([
            cancelImage.topAnchor.pin(equalTo: titleLB.bottomAnchor, constant: 12),
            cancelImage.widthAnchor.pin(equalToConstant: 70.0),
            cancelImage.heightAnchor.pin(equalToConstant: 70.0),
            cancelImage.centerXAnchor.pin(equalTo: dragExitView.centerXAnchor, constant: 0),
        ])
    }
    //MARK: Customer
    func setRemainTimeSeconds(_ seconds: Int) {
        timeLabel.text = L10n("message_audio_record_stop", seconds)
        timeLabel.isHidden = false
    }
    //MARK: Button Action
    @objc func started(_ sender: UIButton) {
        print("\(#function)")
        
        recordingView.isHidden = false
        titleLB.text = L10n("message_audio_record_tip1")
        updateSubviewsConstraint(constant: 135)
        
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
        delegate?.chatBar(didStartToRecord: recorder)
        
    }
    
    @objc func ended(_ sender: UIButton) {
        print("\(#function)")
        recordingView.isHidden = true
        titleLB.text = L10n("message_audio_record_normal")
        updateSubviewsConstraint(constant: 32)
        sendVoiceButton.layer.borderWidth = 3
        sendVoiceButton.setImage(loadImageSafely(with: "btn_send_voice_image"), for: .normal)
        dragExitView.isHidden = true
        
        if !recorder.isRecording { return }
        let interval = recorder.timeInterval
        
        if interval < 1 {
            recorder.cancelRecord()
            timeLabel.text = ""
            delegate?.chatBar(didCancelRecord: recorder)
            HUDHelper.showImage("message_tip_icon", message: L10n("message_audio_record_too_short"))
            return
        } else if interval > 60 {
            if recorder.isRecording { return }
            recorder.cancelRecord()
        } else {
            guard let path = recorder.path else { return }
            let duration = UInt32(round(recorder.timeInterval))
            recorder.stopRecord()
            timeLabel.text = ""
            delegate?.chatBar(didSendAudioWith: path, duration: duration)
        }
    }
    
    @objc func canceled(_ sender: UIButton) {
        print("\(#function)")
        recordingView.isHidden = true
        titleLB.text = L10n("message_audio_record_normal")
        updateSubviewsConstraint(constant: 32)
        sendVoiceButton.layer.insertSublayer(gradientLayer, at: 0)
        sendVoiceButton.layer.borderWidth = 3
        sendVoiceButton.setImage(loadImageSafely(with: "btn_send_voice_image"), for: .normal)
        dragExitView.isHidden = true
        timeLabel.text = ""
        if !recorder.isRecording { return }
        recorder.cancelRecord()
        delegate?.chatBar(didCancelRecord: recorder)
    }
    
    @objc func dragEnter(_ sender: UIButton) {
        print("\(#function)")
        sendVoiceButton.setImage(loadImageSafely(with: "btn_send_voice_image"), for: .normal)
        sendVoiceButton.backgroundColor = UIColor.clear
        sendVoiceButton.layer.insertSublayer(gradientLayer, at: 0)
        sendVoiceButton.layer.borderWidth = 3
        recordingView.isHidden = false
        titleLB.isHidden = false
        dragExitView.isHidden = true
    }
    
    @objc func dragExit(_ sender: UIButton) {
        print("\(#function)")
        recordingView.isHidden = true
        titleLB.isHidden = true
        dragExitView.isHidden = false
        sendVoiceButton.setImage(loadImageSafely(with: "btn_voice_send_continue_img"), for: .normal)
        sendVoiceButton.backgroundColor = UIColor.white
        sendVoiceButton.layer.borderWidth = 0
        gradientLayer.removeFromSuperlayer()
    }
    
    //MARK: updateConstraint
    func updateSubviewsConstraint(constant:CGFloat) {
        topConstraint!.constant = constant
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.layoutIfNeeded()
        }
    }
    
}
extension ZIMKitSendVoiceMessageView : AudioRecorderDelegate {
    func recorder(_ recorder: AudioRecorder, didRecordWith timeInterval: TimeInterval) {
        
        if timeInterval > 50 && timeInterval < 60 {
            setRemainTimeSeconds(Int(60-timeInterval)+1)
        } else if timeInterval < 50{
            let minutes = Int(timeInterval) / 60 % 60
            let seconds = Int(timeInterval) % 60
            timeLabel.text = String(format: "%02i:%02i", minutes, seconds)
        }
        if timeInterval >= 60 {
            endRecord()
        }
    }
    
    func recorderBeginInterruption(_ recorder: AudioRecorder) {
        sendVoiceButton.cancelTracking(with: nil)
    }
    
    func cancelRecord() {
        if !recorder.isRecording { return }
        sendVoiceButton.cancelTracking(with: nil)
    }
    
    func endRecord() {
        if !recorder.isRecording { return }
        guard let path = recorder.path else { return }
        var duration = UInt32(round(recorder.timeInterval))
        if duration > 60 { duration = 60 }
        if duration < 1 { return }
        recorder.stopRecord()
        sendVoiceButton.cancelTracking(with: nil)
        delegate?.chatBar(didSendAudioWith: path, duration: duration)
    }
}

class DotView: UIView {
    
    // 圆点的半径
    let dotRadius: CGFloat = 1.0
    
    // 圆点的颜色
    let dotColor: UIColor = UIColor(hex: 0x94B3FC)
    
    // 圆点的水平间距
    let dotSpacing: CGFloat = 3.0
    
    // 圆点的数量
    let numberOfDots: Int = Int((UIScreen.main.bounds.size.width - 30) / 4)
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // 计算圆点的宽度
        let dotWidth = dotRadius * 2
        
        // 计算圆点的总宽度
        let totalDotWidth = CGFloat(numberOfDots) * dotWidth + CGFloat(numberOfDots - 1) * dotSpacing
        
        // 计算起始点的 x 坐标
        let startX = (rect.width - totalDotWidth) / 2
        
        // 绘制圆点
        for i in 0..<numberOfDots {
            let x = startX + CGFloat(i) * (dotWidth + dotSpacing)
            let y = (rect.height - dotWidth) / 2
            
            let dotRect = CGRect(x: x, y: y, width: dotWidth, height: dotWidth)
            context.setFillColor(dotColor.cgColor)
            context.addEllipse(in: dotRect)
            context.fillPath()
        }
    }
}

