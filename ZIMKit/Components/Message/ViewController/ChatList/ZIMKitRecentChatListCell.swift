//
//  ZIMKitRecentChatListCell.swift
//  ZIMKit
//
//  Created by zego on 2024/8/22.
//

import UIKit

class ZIMKitRecentChatListCell: UITableViewCell {
    class var reuseId: String { String(describing: self) }
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    lazy var conversationAvatar: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 7
        return imageView
    }()
    
    lazy var conversationName: UILabel = {
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
        contentView.addSubview(conversationAvatar)
        contentView.addSubview(conversationName)
        contentView.addSubview(lineView)
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            conversationAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            conversationAvatar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            conversationAvatar.widthAnchor.pin(equalToConstant: 42.0),
            conversationAvatar.heightAnchor.pin(equalToConstant: 42.0)
        ])
        
        NSLayoutConstraint.activate([
            conversationName.leadingAnchor.constraint(equalTo: conversationAvatar.trailingAnchor, constant: 14),
            conversationName.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            conversationName.heightAnchor.pin(equalToConstant: 24.0),
            
        ])
      
      NSLayoutConstraint.activate([
          lineView.heightAnchor.constraint(equalToConstant: 0.5),
          lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -2),
          lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 16),
          lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: 0)
      ])
    }
    
  func configure(with title: String,avatarUrl: String, groupConversation: Bool) {
        conversationName.text = title
    
        var placeHolder = "avatar_default"
        if groupConversation == true {
            placeHolder = "groupAvatar_default"
        }
        
        if avatarUrl.count > 0 && avatarUrl.hasPrefix("http") {
            conversationAvatar.loadImage(with: avatarUrl, placeholder: placeHolder)
        } else {
            conversationAvatar.image = loadImageSafely(with: placeHolder)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
