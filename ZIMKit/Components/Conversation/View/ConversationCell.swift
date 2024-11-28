//
//  ConversationCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/5.
//

import Foundation

class ConversationCell: _TableViewCell {

    static let reuseIdentifier = String(describing: ConversationCell.self)

    lazy var headImageView:UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 7
        return imageView
    }()
    
    lazy var noDisturbingImageView:UIImageView = {
      let imageView = UIImageView().withoutAutoresizingMaskConstraints
      imageView.image = loadImageSafely(with: "icon_message_no_disturbing")
      imageView.clipsToBounds = true
      imageView.layer.cornerRadius = 7
      return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .zim_textBlack1
        return label
    }()

    lazy var subTitleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .zim_textGray1
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .zim_textGray2
        return label
    }()

    lazy var msgFailImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.image = loadImageSafely(with: "conversation_msg_fail")
        return imageView
    }()

    lazy var unReadBubble = UnReadBubble().withoutAutoresizingMaskConstraints

    lazy var line: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundGray3
        contentView.addSubview(view)
        return view
    }()

    var model: ZIMKitConversation? {
        didSet {
            updateContentIfNeeded()
        }
    }
    var messageTrailingConstraint: NSLayoutConstraint!
    var subtitleLeadingConstraint: NSLayoutConstraint!

    override func setUp() {
        super.setUp()

        backgroundColor = .zim_backgroundWhite
        selectionStyle = .none
    }

    override func setUpLayout() {
        super.setUpLayout()

        contentView.addSubview(headImageView)
        contentView.addSubview(noDisturbingImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(line)
        contentView.addSubview(unReadBubble)
        contentView.addSubview(msgFailImageView)

        headImageView.leadingAnchor.pin(
            equalTo: contentView.leadingAnchor,
            constant: 15).isActive = true
        headImageView.pin(to: 48.0)
        headImageView.pin(anchors: [.centerY], to: contentView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.pin(
                equalTo: headImageView.trailingAnchor,
                constant: 11),
            titleLabel.topAnchor.pin(
                equalTo: contentView.topAnchor,
                constant: 15.5),
            titleLabel.trailingAnchor.pin(
                equalTo: timeLabel.leadingAnchor,
                constant: -16),
            titleLabel.heightAnchor.pin(equalToConstant: 22.5)
        ])

        subtitleLeadingConstraint = subTitleLabel.leadingAnchor.pin(equalTo: titleLabel.leadingAnchor)
        messageTrailingConstraint = subTitleLabel.trailingAnchor.pin(equalTo: contentView.trailingAnchor,constant: -28)
        NSLayoutConstraint.activate([
            subtitleLeadingConstraint,
            subTitleLabel.topAnchor.pin(equalTo: titleLabel.bottomAnchor, constant: 4),
            messageTrailingConstraint,
            subTitleLabel.heightAnchor.pin(equalToConstant: 16.5)
        ])
      
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.pin(equalTo: contentView.topAnchor, constant: 20),
            timeLabel.trailingAnchor.pin(equalTo: contentView.trailingAnchor, constant: -16),
            timeLabel.heightAnchor.pin(equalToConstant: 14.0)
        ])
      
        NSLayoutConstraint.activate([
            noDisturbingImageView.centerYAnchor.pin(equalTo: subTitleLabel.centerYAnchor, constant: 0),
            noDisturbingImageView.trailingAnchor.pin(equalTo: contentView.trailingAnchor, constant: -16),
            noDisturbingImageView.heightAnchor.pin(equalToConstant: 14.0),
            noDisturbingImageView.widthAnchor.pin(equalToConstant: 14.0)
        ])

        NSLayoutConstraint.activate([
            line.leadingAnchor.pin(equalTo: titleLabel.leadingAnchor),
            line.heightAnchor.pin(equalToConstant: 0.5)
        ])
        line.pin(anchors: [.trailing, .bottom], to: contentView)

        unReadBubble.leadingAnchor.pin(
            equalTo: headImageView.trailingAnchor,
            constant: -9).isActive = true
        unReadBubble.topAnchor.pin(
            equalTo: headImageView.topAnchor,
            constant: -9).isActive = true
        unReadBubble.pin(to: 18.0)

        msgFailImageView.leadingAnchor.pin(equalTo: titleLabel.leadingAnchor).isActive = true
        msgFailImageView.topAnchor.pin(equalTo: titleLabel.bottomAnchor, constant: 3.5).isActive = true
        msgFailImageView.pin(to: 16.5)
    }

    override func updateContent() {
        super.updateContent()

        guard let model = model else { return }

        // load image
        var placeHolder = "avatar_default"
        if model.type == .group {
            placeHolder = "groupAvatar_default"
        }
        headImageView.loadImage(with: model.avatarUrl, placeholder: placeHolder)

        let userName = model.name.count > 0
            ? model.name
            : model.id
        titleLabel.text = userName

        // update time
        if model.lastMessage?.info.timestamp == 0 {
            timeLabel.text = ""
        } else {
            timeLabel.text = timestampToConversationDateStr(model.lastMessage?.info.timestamp)
        }

        // update subtitle
        subTitleLabel.text = model.lastMessage?.getShortString()
        if model.type == .group {
          if let sendUserName = model.lastMessage?.info.senderUserName,!sendUserName.isEmpty {
            self.subTitleLabel.text = sendUserName  + ": " + (model.lastMessage?.getShortString() ?? "")
          } else {
            ZIMKit.queryUserInfo(by: model.lastMessage?.info.senderUserID ?? "") { [self] userInfo, error in
              if error.code.rawValue == 0 {
                model.lastMessage?.info.senderUserName = userInfo?.name ?? ""
                self.subTitleLabel.text = (userInfo?.name ?? "")  + ": " + (model.lastMessage?.getShortString() ?? "")
              }
            }
          }
        }
      
        unReadBubble.setNum(model.unreadMessageCount)
        noDisturbingImageView.isHidden = (model.notificationStatus == .notify) ? true : false
      
        messageTrailingConstraint.constant = (model.notificationStatus == .notify) ? -28 : -54
        let color = (model.notificationStatus == .doNotDisturb && model.unreadMessageCount > 0) ? UIColor(hex: 0xBABBC0) : .zim_backgroundRed

        unReadBubble.setViewBackGroundColor(color)

      
        msgFailImageView.isHidden = model.lastMessage?.info.sentStatus != .sendFailed

        if model.lastMessage?.info.sentStatus == .sendFailed {
            subtitleLeadingConstraint.constant = 20.5
        } else {
            subtitleLeadingConstraint.constant = 0
        }
        contentView.backgroundColor = (model.isPinned == true) ? UIColor(hex: 0xF8F8F8) : UIColor(hex: 0xFFFFFFF)

        self.layoutIfNeeded()
    }
}
