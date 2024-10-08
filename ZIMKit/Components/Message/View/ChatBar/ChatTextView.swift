//
//  ChatTextView.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/10.
//

import Foundation

let textViewTBMargin: CGFloat = 5
let textViewLRMargin: CGFloat = 10.0

protocol TextViewDelegate: UITextViewDelegate {
    func textViewDeleteBackward(_ textView: TextView)
}

protocol textViewToolBarDelegate: NSObjectProtocol {
    func didClickFullScreenEnter()
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
    
    lazy var placeholderLabel: UILabel = {
        let label:UILabel = UILabel().withoutAutoresizingMaskConstraints
        label.attributedText = ZIMKit().imKitConfig.inputPlaceholder
        //        label.textColor = UIColor(hex: 0x8E9093)
        //        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    lazy var textView: TextView = {
        let textView = TextView().withoutAutoresizingMaskConstraints
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .zim_textBlack1
        textView.backgroundColor = .zim_backgroundWhite
        textView.returnKeyType = .send
        textView.tintColor = UIColor(hex: 0x3478FC)
        textView.autocapitalizationType = .none
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7.0  //行间距
        let fontSize: CGFloat = 15.0
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize), // 字体大小
            NSAttributedString.Key.paragraphStyle: paragraphStyle //段落格式
        ]
        
        textView.typingAttributes = attributes
        return textView
    }()
    
    lazy var fullButton: UIButton = {
        let button: UIButton = UIButton().withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "btn_full_screen_input"), for: .normal)
        button.addTarget(self, action: #selector(fullScreenEnterClick(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    var fullButtonTopConstraint: NSLayoutConstraint!
  
    weak var delegate: textViewToolBarDelegate?
    
    override func setUp() {
        super.setUp()
        
        backgroundColor = .zim_backgroundWhite
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        
        addSubview(textView)
        addSubview(fullButton)
        addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            textView.topAnchor.pin(equalTo: self.topAnchor, constant: textViewTBMargin),
            textView.bottomAnchor.pin(equalTo: self.bottomAnchor, constant: -textViewTBMargin),
            textView.leadingAnchor.pin(equalTo: self.leadingAnchor, constant: textViewLRMargin),
//            textView.trailingAnchor.pin(equalTo: self.trailingAnchor, constant: -(textViewLRMargin + 40)),
            textView.trailingAnchor.pin(equalTo: self.trailingAnchor, constant: -textViewLRMargin)
        ])
        
        fullButtonTopConstraint = fullButton.topAnchor.pin(equalTo: textView.topAnchor, constant: 0)
        NSLayoutConstraint.activate([
            fullButtonTopConstraint,
            fullButton.trailingAnchor.pin(equalTo: self.trailingAnchor, constant: -5),
            fullButton.heightAnchor.pin(equalToConstant: 36),
            fullButton.widthAnchor.pin(equalToConstant: 36)
        ])
       
        fullButtonTopConstraint.isActive = true
      
        NSLayoutConstraint.activate([
            placeholderLabel.centerYAnchor.pin(equalTo: textView.centerYAnchor, constant: 0),
            placeholderLabel.leadingAnchor.pin(equalTo: textView.leadingAnchor, constant: 0),
            placeholderLabel.heightAnchor.pin(equalToConstant: 20)
        ])
    }
    
    @objc func fullScreenEnterClick(_ button :UIButton) {
        textView.resignFirstResponder()
        delegate?.didClickFullScreenEnter()
    }
  
    override func layoutSubviews() {
      super.layoutSubviews()
      
      fullButtonTopConstraint!.constant = self.h > 46 ? 5 : 0

    }
    
}
