//
//  ZIMKitFullScreenEnterView.swift
//  ZIMKit
//
//  Created by zego on 2024/7/30.
//

import UIKit
protocol FullScreenEnterDelegate: NSObjectProtocol {
    func didClickExitFullScreenEnter(content:String)
    func didClickSendMessage(content:String)
}


class ZIMKitFullScreenEnterView: UIView {
    
    var keyboardFrame: CGRect = CGRect(x: 0, y: 10000, width: 0, height: 0)
    var sendButton:UIButton?
    lazy var titleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .zim_textBlack1
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return label
    }()
  
  
     lazy var placeholderLabel: UILabel = {
         let label:UILabel = UILabel().withoutAutoresizingMaskConstraints
         label.text = L10n("enter_new_message")
         label.textColor = UIColor(hex: 0x8E9093)
         label.font = UIFont.systemFont(ofSize: 15)
         return label
     }()
    
    lazy var textView: UITextView = {
        let view = UITextView().withoutAutoresizingMaskConstraints
        view.font = UIFont.systemFont(ofSize: 15)
        view.textColor = .zim_textBlack1
        view.backgroundColor = .zim_backgroundWhite
        view.returnKeyType = .send
        view.delegate = self
        view.tintColor = UIColor(hex: 0x3478FC)

        let topView = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48))
        topView.backgroundColor = UIColor(hex: 0xF5F6F7)
        
        let button = UIButton(frame: CGRect(x: self.bounds.width - 40, y: 8, width: 32, height: 32))
        button.setImage(loadImageSafely(with: "btn_send"), for: .normal)
        button.setImage(loadImageSafely(with: "btn_send_no_enable"), for: .disabled)
        button.addTarget(self, action: #selector(sendMessageAction), for: .touchUpInside)
        button.isEnabled = false
        topView.addSubview(button)
        view.inputAccessoryView = topView
        self.sendButton = button
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundWhite
        view.clipsToBounds = true
        return view
    }()
    
    lazy var fullButton: UIButton = {
        let button: UIButton = UIButton().withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "btn_exit_full_screen"), for: .normal)
        button.addTarget(self, action: #selector(exitFullScreenEnterClick(_:)), for: .touchUpInside)
        
        return button
    }()
    
    weak var delegate: FullScreenEnterDelegate?
    
    public init(content:String,conversationName:String) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor(hex: 0x000000, a: 0.4)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        titleLabel.text = L10n("send_message") + " " + conversationName
        textView.text = content
        textView.becomeFirstResponder()
        
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.pin(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            contentView.leadingAnchor.pin(equalTo: leadingAnchor),
            contentView.trailingAnchor.pin(equalTo: trailingAnchor),
            //            contentView.bottomAnchor.pin(equalTo: bottomAnchor),
        ])
        
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.pin(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.pin(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.heightAnchor.pin(equalToConstant: 22),
        ])
        
        contentView.addSubview(fullButton)
        NSLayoutConstraint.activate([
            fullButton.centerYAnchor.pin(equalTo: titleLabel.centerYAnchor),
            fullButton.trailingAnchor.pin(equalTo: contentView.trailingAnchor, constant: -13),
            fullButton.widthAnchor.pin(equalToConstant: 36),
            fullButton.heightAnchor.pin(equalToConstant: 36)
            
        ])
        
        contentView.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.pin(equalTo: titleLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.pin(equalTo: contentView.leadingAnchor, constant: 20),
            textView.trailingAnchor.pin(equalTo: contentView.trailingAnchor,constant: -20),
            textView.bottomAnchor.pin(equalTo: contentView.bottomAnchor, constant: 0),
        ])
        textView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.pin(equalTo: textView.topAnchor, constant: 10),
            placeholderLabel.leadingAnchor.pin(equalTo: textView.leadingAnchor, constant: 3),
            placeholderLabel.heightAnchor.pin(equalToConstant: 20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskPath = UIBezierPath(roundedRect: contentView.bounds,
                                    byRoundingCorners: [.topLeft,.topRight],
                                    cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.white.cgColor
        maskLayer.path = maskPath.cgPath
        contentView.layer.mask = maskLayer
        
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
    
    @objc private func keyboardWillChangeFrame(_ noti: Notification) {
        guard let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        keyboardFrame = frame
        let bottomConstraint = contentView.bottomAnchor.pin(equalTo: bottomAnchor,constant: -keyboardFrame.height)
        bottomConstraint.isActive = true
        contentView.layoutIfNeeded()
    }
    
    @objc func exitFullScreenEnterClick(_ button :UIButton) {
        endEditingAndExitFullScreen()
        delegate?.didClickExitFullScreenEnter(content: textView.text)
    }
    
    @objc func sendMessageAction() {
        endEditingAndExitFullScreen()
        delegate?.didClickSendMessage(content: textView.text)
    }
    
    func endEditingAndExitFullScreen() {
//        textView.resignFirstResponder()
        hideView()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

extension ZIMKitFullScreenEnterView :UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {  // 检测到 return 键
            endEditingAndExitFullScreen()
            delegate?.didClickSendMessage(content: textView.text)
            return false  // 阻止默认的换行行为
        }
      return true
    }
  
  func textViewDidChange(_ textView: UITextView) {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 7.0  //行间距
    let fontSize: CGFloat = 15.0

    let attributedString = NSAttributedString(string: textView.text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize), NSAttributedString.Key.paragraphStyle: paragraphStyle])
    textView.attributedText = attributedString
    sendButton?.isEnabled = textView.text.count > 0 ? true : false
    placeholderLabel.isHidden = textView.text.count > 0 ? true : false
  }
}
