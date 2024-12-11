//
//  ChatTextView.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/10.
//

import Foundation

let textViewTBMargin: CGFloat = 5
let textViewLRMargin: CGFloat = 10.0

protocol TextViewCancelReplyMessageDelegate: NSObjectProtocol {
    func chatTextCancelReplyMessage()
}

protocol TextViewDelegate: UITextViewDelegate {
    func textViewDeleteBackward(_ textView: TextView)
}

protocol textViewToolBarDelegate: NSObjectProtocol {
    func didClickFullScreenEnter()
    func didClicksendMessage()
}


class TextView: UITextView {
    
    override func deleteBackward() {
        if let delegate = delegate as? TextViewDelegate {
            delegate.textViewDeleteBackward(self)
        }
        super.deleteBackward()
    }
    
    override var text: String! {
        didSet {
            delegate?.textViewDidChange?(self)
        }
    }
}

class ChatTextView: _View {
    
    var sendButton:UIButton?
    
    lazy var placeholderLabel: UILabel = {
        let label:UILabel = UILabel().withoutAutoresizingMaskConstraints
        label.attributedText = ZIMKit().imKitConfig.inputPlaceholder
        return label
    }()
    
    lazy var textView: TextView = {
        let view = TextView().withoutAutoresizingMaskConstraints
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = .zim_textBlack1
        view.backgroundColor = .zim_backgroundWhite
        view.returnKeyType = .default
        view.tintColor = UIColor(hex: 0x3478FC)
//        view.autocapitalizationType = .none
        
        
        let topView = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48))
        topView.backgroundColor = UIColor(hex: 0xF5F6F7)
        
        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - 40, y: 8, width: 32, height: 32))
        button.setImage(loadImageSafely(with: "btn_send"), for: .normal)
        button.setImage(loadImageSafely(with: "btn_send_no_enable"), for: .disabled)
        button.addTarget(self, action: #selector(sendMessageAction), for: .touchUpInside)
        button.isEnabled = false
        topView.addSubview(button)
        view.inputAccessoryView = topView
        self.sendButton = button
        return view
    }()
    
    lazy var fullButton: UIButton = {
        let button: UIButton = UIButton().withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "btn_full_screen_input"), for: .normal)
        button.addTarget(self, action: #selector(fullScreenEnterClick(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var replyBriefView:ChatBarReplyMessageBriefView = {
        let view = ChatBarReplyMessageBriefView().withoutAutoresizingMaskConstraints
        view.isHidden = true
        view.delegate = self
        return view
    }()
    
    var fullButtonTopConstraint: NSLayoutConstraint!
    var textviewTopConstraint: NSLayoutConstraint!
    var replyingMessage:Bool = false
    weak var delegate: textViewToolBarDelegate?
    weak var replyDelegate: TextViewCancelReplyMessageDelegate?
    override func setUp() {
        super.setUp()
        
        backgroundColor = .zim_backgroundWhite
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        setUpSubViews()
    }
    
    func setUpSubViews() {
        addSubview(textView)
        addSubview(fullButton)
        textView.addSubview(placeholderLabel)
        addSubview(replyBriefView)
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        
        textviewTopConstraint = textView.topAnchor.pin(equalTo: self.topAnchor, constant: textViewTBMargin)
        NSLayoutConstraint.activate([
            textviewTopConstraint,
            textView.bottomAnchor.pin(equalTo: self.bottomAnchor, constant: -textViewTBMargin),
            textView.leadingAnchor.pin(equalTo: self.leadingAnchor, constant: textViewLRMargin),
            textView.trailingAnchor.pin(equalTo: self.trailingAnchor, constant: -textViewLRMargin - 36)
        ])
        textviewTopConstraint.isActive = true
        
        
        fullButtonTopConstraint = fullButton.topAnchor.pin(equalTo: textView.topAnchor, constant: 0)
        NSLayoutConstraint.activate([
            fullButtonTopConstraint,
            fullButton.trailingAnchor.pin(equalTo: self.trailingAnchor, constant: -5),
            fullButton.heightAnchor.pin(equalToConstant: 36),
            fullButton.widthAnchor.pin(equalToConstant: 36)
        ])
        
        fullButtonTopConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            placeholderLabel.centerYAnchor.pin(equalTo: textView.centerYAnchor,constant: 0),
            placeholderLabel.leadingAnchor.pin(equalTo: textView.leadingAnchor, constant: 6),
            placeholderLabel.heightAnchor.pin(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            replyBriefView.topAnchor.pin(equalTo: topAnchor, constant: 10),
            replyBriefView.leadingAnchor.pin(equalTo: leadingAnchor, constant: 12),
            replyBriefView.trailingAnchor.pin(equalTo: trailingAnchor, constant: -12),
            replyBriefView.heightAnchor.pin(equalToConstant: 30)
        ])
    }
    
    @objc func fullScreenEnterClick(_ button :UIButton) {
        textView.resignFirstResponder()
        delegate?.didClickFullScreenEnter()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fullButtonTopConstraint!.constant = textView.h > chatViewDefaultHeight ? 5 : 0
        textviewTopConstraint.constant = replyingMessage ? 51 : textViewTBMargin
        textviewTopConstraint.isActive = true
        fullButtonTopConstraint.isActive = true
        
    }
    
    func didBeginReplyMessage(fromUserName:String,content:String) {
        replyingMessage = true
        replyBriefView.isHidden = false
        replyBriefView.updateReplyBriefContent(fromUserName: fromUserName, content: content)
        textView.becomeFirstResponder()
    }
    
    func cancelReplyState() {
        replyingMessage = false
        replyBriefView.isHidden = true
        replyBriefView.replyBriefLabel.text = ""
        replyDelegate?.chatTextCancelReplyMessage()
    }
    
    @objc func sendMessageAction() {
        delegate?.didClicksendMessage()
    }
    
}

extension ChatTextView: CancelReplyMessageDelegate {
    func cancelMessageReply() {
        cancelReplyState()
    }
}
