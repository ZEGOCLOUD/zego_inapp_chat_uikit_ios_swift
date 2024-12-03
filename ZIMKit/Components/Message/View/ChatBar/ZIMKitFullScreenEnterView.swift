//
//  ZIMKitFullScreenEnterView.swift
//  ZIMKit
//
//  Created by zego on 2024/7/30.
//

import UIKit
protocol FullScreenEnterDelegate: NSObjectProtocol {
    func didClickExitFullScreenEnter(content:String,cursorPosition:Int)
    func didClickSendMessage(content:String)
    func didClickReplyMessage(content:String)
}


class ZIMKitFullScreenEnterView: UIView {
    var replyMsg:Bool = false
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
        view.returnKeyType = .default
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
    
    lazy var replyTitle : UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.backgroundColor = UIColor(hex: 0xF2F3F5)
        label.alpha = 0.9
        label.textColor = UIColor(hex: 0x646A73)
        label.font = UIFont.systemFont(ofSize: 13)
        label.clipsToBounds = true
        label.layer.cornerRadius = 4
        label.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return label
    }()
    
    lazy var fullButton: UIButton = {
        let button: UIButton = UIButton().withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "btn_exit_full_screen"), for: .normal)
        button.addTarget(self, action: #selector(exitFullScreenEnterClick(_:)), for: .touchUpInside)
        
        return button
    }()
    
    weak var delegate: FullScreenEnterDelegate?
    
    public init(content:String,conversationName:String,replyMessage:String = "",cursorPosition:Int = 0) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor(hex: 0x000000, a: 0.4)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        replyMsg = replyMessage.count > 0
        
        titleLabel.text = L10n("send_message") + " " + conversationName
        setTextViewAttributedString(text: content)
        textView.becomeFirstResponder()
        
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.pin(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            contentView.leadingAnchor.pin(equalTo: leadingAnchor),
            contentView.trailingAnchor.pin(equalTo: trailingAnchor),
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
        
        replyTitle.isHidden = !replyMsg
        replyTitle.text = "  " + replyMessage
        contentView.addSubview(replyTitle)
        NSLayoutConstraint.activate([
            replyTitle.topAnchor.pin(equalTo: titleLabel.bottomAnchor, constant: 12),
            replyTitle.leadingAnchor.pin(equalTo: leadingAnchor,constant: 20),
            replyTitle.trailingAnchor.pin(equalTo: trailingAnchor,constant: -20),
            replyTitle.heightAnchor.pin(equalToConstant: 30),
        ])
        
        var textViewTopConstraint: NSLayoutConstraint!
        if replyMessage.count <= 0 {
            textViewTopConstraint = textView.topAnchor.pin(equalTo: titleLabel.bottomAnchor, constant: 12)
        } else {
            textViewTopConstraint = textView.topAnchor.pin(equalTo: replyTitle.bottomAnchor, constant: 12)
        }
        
        contentView.addSubview(textView)
        NSLayoutConstraint.activate([
            textViewTopConstraint,
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
        placeholderLabel.isHidden = textView.text.count > 0 ? true : false
        sendButton?.isEnabled = textView.text.count > 0 ? true : false
        textView.selectedRange = NSRange(location: cursorPosition, length: 0)
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
        delegate?.didClickExitFullScreenEnter(content: textView.text,cursorPosition: textView.selectedRange.location)
    }
    
    @objc func sendMessageAction() {
        endEditingAndExitFullScreen()
        if replyMsg {
            delegate?.didClickReplyMessage(content: textView.text)
        } else {
            delegate?.didClickSendMessage(content: textView.text)
        }
    }
    
    func endEditingAndExitFullScreen() {
        //        textView.resignFirstResponder()
        hideView()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func setTextViewAttributedString(text:String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7.0  //行间距
        let fontSize: CGFloat = 15.0
        
        let attributedString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize), NSAttributedString.Key.paragraphStyle: paragraphStyle])
        if let lang = textView.textInputMode?.primaryLanguage, lang == "zh-Hans" {
            if textView.markedTextRange == nil {
                textView.attributedText = attributedString
            } else {
                
            }
        } else {
            textView.attributedText = attributedString
        }
        sendButton?.isEnabled = textView.text.count > 0 ? true : false
        placeholderLabel.isHidden = textView.text.count > 0 ? true : false
    }
    func insertTextAfterCursor(_ newCursorPosition:Int) {
        let beginning = textView.beginningOfDocument
        let newPosition = textView.position(from: beginning, offset: newCursorPosition)
        textView.selectedTextRange = textView.textRange(from: newPosition!, to: newPosition!)
        textView.selectedRange = NSRange(location: newCursorPosition, length: 0)
    }
}

extension ZIMKitFullScreenEnterView :UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {  // 检测到 return 键
//            endEditingAndExitFullScreen()
//            if replyMsg {
//                delegate?.didClickReplyMessage(content: textView.text)
//            } else {
//                delegate?.didClickSendMessage(content: textView.text)
//            }
            return true  // 阻止默认的换行行为
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let newCursorPosition = textView.selectedRange.location
        setTextViewAttributedString(text: textView.text)
        insertTextAfterCursor(newCursorPosition)

    }
}
