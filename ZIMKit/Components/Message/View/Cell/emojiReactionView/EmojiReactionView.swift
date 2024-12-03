//
//  ReplyEmojiView.swift
//  Kingfisher
//
//  Created by zego on 2024/9/6.
//

import UIKit
import ZIM
class EmojiReactionView: UIView {

    lazy var contentLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .zim_textBlack1
        return label
    }()
    
    lazy var sendUsersLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hex: 0xFFFFFF, a: 0.7)
        return label
    }()

    lazy var lineView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = UIColor(hex: 0xFFFFFF,a: 0.2)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        backgroundColor = UIColor(hex: 0x1A63F1)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        addSubview(contentLabel)
        addSubview(lineView)
        addSubview(sendUsersLabel)
        
        NSLayoutConstraint.activate([
            contentLabel.centerYAnchor.pin(equalTo: centerYAnchor),
            contentLabel.leadingAnchor.pin(equalTo: leadingAnchor,constant: 8),
            contentLabel.heightAnchor.pin(equalToConstant: 18),
            contentLabel.widthAnchor.pin(equalToConstant: 18),
            
            lineView.centerYAnchor.pin(equalTo: contentLabel.centerYAnchor),
            lineView.leadingAnchor.pin(equalTo: contentLabel.trailingAnchor,constant: 4),
            lineView.heightAnchor.pin(equalToConstant: 14),
            lineView.widthAnchor.pin(equalToConstant: 1),
            
            sendUsersLabel.centerYAnchor.pin(equalTo: contentLabel.centerYAnchor),
            sendUsersLabel.leadingAnchor.pin(equalTo: lineView.trailingAnchor,constant: 5),
            sendUsersLabel.heightAnchor.pin(equalToConstant: 15),
            sendUsersLabel.trailingAnchor.pin(equalTo: trailingAnchor,constant: -8)
        ])

    }
    
    func updateContent(content:String,sendUserName:String) {
        contentLabel.text = content
        sendUsersLabel.text = sendUserName
    }
    
    func updateSubViewsColor(direction:ZIMMessageDirection) {
        if direction == .send {
            backgroundColor = UIColor(hex: 0x1A63F1)
            sendUsersLabel.textColor = UIColor(hex: 0xFFFFFF,a: 0.7)
            lineView.backgroundColor = UIColor(hex: 0xFFFFFF,a: 0.2)
        } else {
            backgroundColor = UIColor(hex: 0xEFF0F2)
            sendUsersLabel.textColor = UIColor(hex: 0x646A73)
            lineView.backgroundColor = UIColor(hex: 0xCACBCE)
        }
    }
}
