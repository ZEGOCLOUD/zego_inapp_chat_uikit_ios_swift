//
//  ZIMKitGroupMemberInfoTableViewCell.swift
//  ZIMKit
//
//  Created by zego on 2024/7/25.
//

import UIKit

class ZIMKitGroupMemberInfoTableViewCell: UITableViewCell {
    class var reuseId: String { String(describing: self) }
    lazy var memberAvatar: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 7
        return imageView
    }()
    
    lazy var memberName: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .zim_textBlack1
        return label
    }()
    
    lazy var lineView: UIView = {
        let view: UIView = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = UIColor(hex: 0xE6E6E6)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(memberAvatar)
        contentView.addSubview(memberName)
        contentView.addSubview(lineView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            memberAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            memberAvatar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            memberAvatar.widthAnchor.pin(equalToConstant: 42.0),
            memberAvatar.heightAnchor.pin(equalToConstant: 42.0)
        ])
        
        NSLayoutConstraint.activate([
            memberName.leadingAnchor.constraint(equalTo: memberAvatar.trailingAnchor, constant: 14),
            memberName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            memberName.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            memberName.heightAnchor.pin(equalToConstant: 24.0),
        ])
        
        NSLayoutConstraint.activate([
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
            lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -2),
            lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 16),
            lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: 0)
        ])
    }
    
    func configure(with title: String,avatarUrl: String) {
        memberName.text = title
        if avatarUrl.count > 0 && avatarUrl.hasPrefix("http") {
            memberAvatar.loadImage(with: avatarUrl, placeholder: "avatar_default")
        } else {
            memberAvatar.image = loadImageSafely(with: "avatar_default")
        }
    }
    
}
