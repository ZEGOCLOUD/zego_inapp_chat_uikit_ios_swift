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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(memberAvatar)
        contentView.addSubview(memberName)
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
            memberName.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            memberName.heightAnchor.pin(equalToConstant: 24.0),
            
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
