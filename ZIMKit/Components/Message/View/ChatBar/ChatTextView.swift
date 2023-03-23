//
//  ChatTextView.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/10.
//

import Foundation

let textViewTBMargin: CGFloat = 6
let textViewLRMargin: CGFloat = 12.0

protocol TextViewDelegate: UITextViewDelegate {
    func textViewDeleteBackward(_ textView: TextView)
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

    lazy var textView: TextView = {
        let textView = TextView().withoutAutoresizingMaskConstraints
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .zim_textBlack1
        textView.backgroundColor = .zim_backgroundGray1
        textView.returnKeyType = .send
        return textView
    }()

    override func setUp() {
        super.setUp()

        backgroundColor = .zim_backgroundGray1
        layer.cornerRadius = 12.0
        layer.masksToBounds = true
    }

    override func setUpLayout() {
        super.setUpLayout()

        addSubview(textView)
        embed(textView, insets: .init(
                top: textViewTBMargin,
                leading: textViewLRMargin,
                bottom: textViewTBMargin,
                trailing: textViewLRMargin))
    }
}
