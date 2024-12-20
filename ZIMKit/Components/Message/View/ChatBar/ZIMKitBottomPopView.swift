//
//  ZIMKitBottomPopView.swift
//  ZIMKit
//
//  Created by zego on 2024/7/30.
//

import UIKit
import ZegoPluginAdapter

protocol voiceAndVideoCallDelegate: AnyObject {
    
    func didSelectedVoiceAndVideoCall(videoCall:Bool)
}

class ZIMKitBottomPopView: UIView {
    
    lazy var containerView: UIView = {
        let view: UIView = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundWhite
        view.clipsToBounds = true
        return view
    }()
    
    var dataList:[ZIMKitMenuBarButtonName] = []
    var delegate: voiceAndVideoCallDelegate?
    init(callList:[ZIMKitMenuBarButtonName]) {
        super.init(frame: UIScreen.main.bounds)
        dataList = callList
        setupViews()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapClick))
        self.addGestureRecognizer(tap)
    }
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setTitle(L10n("message_btn_cancle"), for:.normal)
        button.setTitleColor(.zim_textBlack1, for:.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.addTarget(self, action: #selector(cancelItemClick(_:)), for: .touchUpInside)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .zim_backgroundWhite
        return button
    }()
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = UIColor(hex: 0x000000, a: 0.4)
        
        addSubview(containerView)
        let UIKitKeyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        let bottomMargin = (UIKitKeyWindow?.safeAreaInsets.bottom)! + 12
        let topMargin = 12.0
        // 布局设置
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: bottomMargin + topMargin + 50 + CGFloat(dataList.count * 50))
        ])
        containerView.addSubview(cancelButton)
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -bottomMargin),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        var voiceCall: UIView = UIView()
        if dataList.contains(.voiceCall) {
            voiceCall = createItemView(title: L10n("audio_call"), imageName: "icon_audio_call")
            let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(voiceCallClick))
            voiceCall.addGestureRecognizer(tap)
            containerView.addSubview(voiceCall)
            NSLayoutConstraint.activate([
                voiceCall.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                voiceCall.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                voiceCall.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
                voiceCall.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        if dataList.contains(.videoCall) {
            let videoCall: UIView = createItemView(title: L10n("video_call"), imageName: "icon_video_call")
            let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(videoCallClick))
            videoCall.addGestureRecognizer(tap)
            containerView.addSubview(videoCall)
            NSLayoutConstraint.activate([
                videoCall.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                videoCall.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                videoCall.topAnchor.constraint(equalTo: voiceCall.bottomAnchor, constant: 0),
                videoCall.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
    }
    
    
    @objc func voiceCallClick() {
        hideView()
        delegate?.didSelectedVoiceAndVideoCall(videoCall: false)
    }
    
    @objc func videoCallClick() {
        hideView()
        delegate?.didSelectedVoiceAndVideoCall(videoCall: true)
    }
    
    @objc func cancelItemClick(_ sender: UIButton) {
        hideView()
    }
    
    
    func createItemView(title:String,imageName:String) -> UIView {
        let view: UIView = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundWhite
        
        let label: UILabel = UILabel().withoutAutoresizingMaskConstraints
        label.text = title
        label.textColor = .zim_textBlack1
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        let imageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.image = loadImageSafely(with: imageName)
        
        let lineView: UIView = UIView().withoutAutoresizingMaskConstraints
        lineView.backgroundColor = UIColor(hex: 0xE6E6E6)
        
        view.addSubview(label)
        view.addSubview(imageView)
        view.addSubview(lineView)
        
        let viewWidth:CGFloat = label.intrinsicContentSize.width + 12.0 + 24.0
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor,constant: 13),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -13),
            imageView.leadingAnchor.constraint(equalTo: view.centerXAnchor,constant: -viewWidth / 2.0),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            imageView.widthAnchor.constraint(equalToConstant: 24)
        ])
        
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 21),
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor,constant: 12)
        ])
        
        NSLayoutConstraint.activate([
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
            lineView.topAnchor.constraint(equalTo: imageView.bottomAnchor,constant: 12),
            lineView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            lineView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24)
        ])
        
        return view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskPath = UIBezierPath(roundedRect: containerView.bounds,
                                    byRoundingCorners: [.topLeft,.topRight],
                                    cornerRadii: CGSize(width: 8, height: 8))
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.white.cgColor
        maskLayer.path = maskPath.cgPath
        containerView.layer.mask = maskLayer
    }
    
    @objc func tapClick() {
        hideView()
    }
    
    func showView() {
        if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            self.alpha = 0
            keyWindow.addSubview(self)
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            } completion: { (finished) in
            }
        }
    }
    
    func hideView() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { (finished) in
            self.removeFromSuperview()
        }
    }
}
