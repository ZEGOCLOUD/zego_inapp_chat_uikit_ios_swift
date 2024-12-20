//
//  MessageCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/17.
//

import Foundation

protocol MessageCellDelegate: AnyObject {
    func messageCell(_ cell: MessageCell, longPressWith messageViewModel: MessageViewModel)
    func onClickEmojiReaction(_ cell: MessageCell,emoji: String)
}

class MessageCell: _TableViewCell {
    
    class var reuseId: String {
        String(describing: MessageCell.self)
    }
    
    lazy var timeLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .zim_textGray2
        return label
    }()
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.contentMode = .scaleAspectFill
        imageView.image = loadImageSafely(with: "avatar_default")
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textAlignment = .left
        label.textColor = .zim_textGray5
        return label
    }()
    
    lazy var containerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var indicator: LoadingView = {
        let loadingView = LoadingView(frame: CGRectMake(0, 0, 20, 20)).withoutAutoresizingMaskConstraints
        loadingView.isHidden = true
        return loadingView
    }()
    
    lazy var retryButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "message_send_fail"), for: .normal)
        return button
    }()
    
    lazy var selectIcon = UIImageView().withoutAutoresizingMaskConstraints
    lazy var selectButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.backgroundColor = .clear
        return button
    }()
    
    lazy var revokeLabel: UILabel = {
        let label :UILabel = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .zim_textGray2
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()
    
    lazy var tipsLabel: UILabel = {
        let label :UILabel = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .zim_textGray2
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.isHidden = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var progressView: CircularProgressView = {
        let view = CircularProgressView().withoutAutoresizingMaskConstraints
        view.isHidden = true
        view.backgroundColor = UIColor(hex: 0x000000, a: 0.5)
        return view
    }()
    
    
    lazy var emojiContentView: ChatReactionView = {
        let view = ChatReactionView().withoutAutoresizingMaskConstraints
        view.isHidden = true
        return view
    }()
    
    var emojiViewWidthConstraint: NSLayoutConstraint!
    var emojiViewHeightConstraint: NSLayoutConstraint!
    
    var messageVM: MessageViewModel? {
        didSet {
            updateContentIfNeeded()
        }
    }
    
    weak var delegate: MessageCellDelegate?
    
    private var avatarTopConstraint: NSLayoutConstraint!
    private var avatarHorizontalConstraint: NSLayoutConstraint!
    private var nameHorizontalConstraint: NSLayoutConstraint!
    var containerWidthConstraint: NSLayoutConstraint!
    private var containerHeightConstraint: NSLayoutConstraint!
    private var containerTopConstraint: NSLayoutConstraint!
    private var containerHorizontalConstraint: NSLayoutConstraint!
    private var retryButtonHorizontalConstraint: NSLayoutConstraint!
    
    override func setUp() {
        super.setUp()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        containerView.addGestureRecognizer(longPress)
        self.emojiContentView.delegate = self

        selectButton.addTarget(self, action: #selector(selectButtonClick), for: .touchUpInside)
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        
        contentView.addSubview(timeLabel)
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.pin(equalTo: contentView.centerXAnchor),
            timeLabel.topAnchor.pin(equalTo: contentView.topAnchor, constant: 4),
            timeLabel.heightAnchor.pin(equalToConstant: 16.5)
        ])
        
        contentView.addSubview(avatarImageView)
        avatarImageView.pin(to: 43.0)
        updateAvatarConstraint()
        
        contentView.addSubview(selectIcon)
        selectIcon.pin(to: 23.0)
        selectIcon.leadingAnchor.pin(equalTo: contentView.leadingAnchor, constant: 8.0).isActive = true
        selectIcon.centerYAnchor.pin(equalTo: avatarImageView.centerYAnchor).isActive = true
        
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.pin(equalTo: avatarImageView.topAnchor),
            nameLabel.widthAnchor.pin(equalToConstant: 160),
            nameLabel.heightAnchor.pin(equalToConstant: 15)
        ])
        updateNameLabelConstraint()
        
        contentView.addSubview(containerView)
        containerWidthConstraint = containerView.widthAnchor.pin(equalToConstant: 0)
        containerHeightConstraint = containerView.heightAnchor.pin(equalToConstant: 0)
        containerWidthConstraint.isActive = true
        containerHeightConstraint.isActive = true
        updateContainerConstraint()
        
        contentView.addSubview(retryButton)
        NSLayoutConstraint.activate([
            retryButton.bottomAnchor.pin(equalTo: containerView.bottomAnchor),
            retryButton.widthAnchor.pin(equalToConstant: 20.0),
            retryButton.heightAnchor.pin(equalToConstant: 20.0)
        ])
        updateRetryButtonConstraint()
        
        contentView.addSubview(indicator)
        indicator.pin(to: retryButton)
        
        contentView.embed(selectButton)
        
        containerView.addSubview(emojiContentView)
        emojiViewWidthConstraint = emojiContentView.widthAnchor.pin(equalToConstant: (messageVM?.contentSize.width ?? 80)  - 24)
        emojiViewHeightConstraint = emojiContentView.heightAnchor.pin(equalToConstant: messageVM?.reactionHeight ?? 24)
        NSLayoutConstraint.activate([
            emojiContentView.leadingAnchor.pin(equalTo: containerView.leadingAnchor, constant: 12),
            emojiContentView.bottomAnchor.pin(equalTo: containerView.bottomAnchor, constant: -10),
            emojiViewWidthConstraint,
            emojiViewHeightConstraint
        ])
    }
    
    private func updateAvatarConstraint() {
        // inActive pre constraint
        if avatarTopConstraint != nil {
            avatarTopConstraint.isActive = false
        }
        if avatarHorizontalConstraint != nil {
            avatarHorizontalConstraint.isActive = false
        }
        
        avatarTopConstraint = avatarImageView.topAnchor.pin(equalTo: contentView.topAnchor)
        if messageVM?.isShowTime == true {
            avatarTopConstraint = avatarImageView.topAnchor.pin(
                equalTo: timeLabel.bottomAnchor,
                constant: 12)
        }
        let leadingConstant = messageVM?.isShowCheckBox == true ? 39.0 : 8.0
        avatarHorizontalConstraint = avatarImageView.leadingAnchor.pin(
            equalTo: contentView.leadingAnchor,
            constant: leadingConstant)
        if messageVM?.message.info.direction == .send {
            avatarHorizontalConstraint =  avatarImageView.trailingAnchor.pin(equalTo: contentView.trailingAnchor, constant: -8)
        }
        avatarTopConstraint.isActive = true
        avatarHorizontalConstraint.isActive = true
    }
    
    private func updateNameLabelConstraint() {
        if nameHorizontalConstraint != nil {
            nameHorizontalConstraint.isActive = false
        }
        nameHorizontalConstraint = nameLabel.leadingAnchor.pin(
            equalTo: avatarImageView.trailingAnchor,
            constant: 12)
        if messageVM?.message.info.direction == .send {
            nameHorizontalConstraint = nameLabel.trailingAnchor.pin(
                equalTo: avatarImageView.leadingAnchor,
                constant: -12)
        }
        nameHorizontalConstraint.isActive = true
    }
    
    private func updateContainerConstraint() {
        
        var contentW = 0.0
        var contentH = 0.0
        if let message = messageVM {
            var contentViewWidth = 0.0
            if message.message.reactions.count > 0 {
                contentViewWidth = max((message.containerViewWidth + 24), message.contentSize.width)
            } else {
                contentViewWidth = message.contentSize.width
            }
            contentW = contentViewWidth + message.cellConfig.contentInsets.left * 2
            contentH = message.contentSize.height + message.cellConfig.contentInsets.top * 2
            if message.reactionHeight > 0 {
                contentH += message.reactionHeight + 10
            }
        }
        containerWidthConstraint.constant = contentW
        containerHeightConstraint.constant = contentH
        
        if containerTopConstraint != nil {
            containerTopConstraint.isActive = false
        }
        if containerHorizontalConstraint != nil {
            containerHorizontalConstraint.isActive = false
        }
        containerTopConstraint = containerView.topAnchor.pin(equalTo: avatarImageView.topAnchor)
        if messageVM?.isShowName == true {
            containerTopConstraint = containerView.topAnchor.pin(
                equalTo: nameLabel.bottomAnchor,
                constant: 2)
        }
        containerTopConstraint.isActive = true
        
        containerHorizontalConstraint = containerView.leadingAnchor.pin(
            equalTo: avatarImageView.trailingAnchor,
            constant: 12)
        if messageVM?.message.info.direction == .send {
            containerHorizontalConstraint = containerView.trailingAnchor.pin(
                equalTo: avatarImageView.leadingAnchor,
                constant: -12)
        }
        containerHorizontalConstraint.isActive = true
        
        emojiViewWidthConstraint?.constant = ((messageVM?.containerViewWidth ?? 24) - 24)
        emojiViewHeightConstraint?.constant = messageVM?.reactionHeight ?? 24.0
        
    }
    
    private func updateRetryButtonConstraint() {
        if retryButtonHorizontalConstraint != nil {
            retryButtonHorizontalConstraint.isActive = false
        }
        retryButtonHorizontalConstraint = retryButton.leadingAnchor.pin(
            equalTo: containerView.trailingAnchor,
            constant: 8)
        if messageVM?.message.info.direction == .send {
            retryButtonHorizontalConstraint = retryButton.trailingAnchor.pin(
                equalTo: containerView.leadingAnchor,
                constant: -8)
        }
        retryButtonHorizontalConstraint.isActive = true
    }
    
    override func updateContent() {
        super.updateContent()
        
        guard let messageVM = messageVM else { return }
        let message = messageVM.message
        
        updateAvatarConstraint()
        updateNameLabelConstraint()
        updateContainerConstraint()
        updateRetryButtonConstraint()
        
        if message.type != .image && message.type != .video {
            if message.info.sentStatus == .sending && message.info.direction == .send {
                indicator.startAnimation()
            } else {
                indicator.stopAnimation()
            }
        }
        
        timeLabel.isHidden = !messageVM.isShowTime
        if messageVM.isShowTime {
            timeLabel.text = timestampToMessageDateStr(message.info.timestamp)
        }
        
        updateSenderUserInfo()
        
        retryButton.isHidden = !(message.info.sentStatus == .sendFailed && message.info.direction == .send)
        
        selectIcon.isHidden = !messageVM.isShowCheckBox
        selectButton.isHidden = !messageVM.isShowCheckBox
        selectIcon.image = loadImageSafely(
            with: messageVM.isSelected
            ? "message_multiSelect_selected"
            : "message_multiSelect_normal")
        if messageVM.message.type == .revoke || messageVM.message.type == .unknown || messageVM.message.type == .custom  || messageVM.message.type == .system || messageVM.message.type == .tips || messageVM.message.info.sentStatus == .sendFailed {
            selectIcon.isHidden = true
            selectButton.isHidden = true
        }
        
        if message.reactions.count > 0 {
            emojiContentView.isHidden = false
            emojiContentView.setUpSubViews(reactions: messageVM.message.reactions, maxWidth: ceil(messageVM.containerViewWidth), userNames: messageVM.reactionUserNames,direction: messageVM.message.info.direction)
        } else {
            emojiContentView.isHidden = true
        }
        containerView.bringSubviewToFront(emojiContentView)
        emojiViewWidthConstraint?.constant = messageVM.containerViewWidth
        emojiViewHeightConstraint?.constant = messageVM.reactionHeight
    }
    
    func updateSenderUserInfo() {
        guard let messageVM = messageVM else { return }
        let message = messageVM.message
        if message.info.senderUserAvatarUrl?.count ?? 0 <= 0 {
            return
        }
        avatarImageView.loadImage(with: message.info.senderUserAvatarUrl, placeholder: "avatar_default")
        
        nameLabel.isHidden = !messageVM.isShowName
        if messageVM.isShowName {
            var name = message.info.senderUserName ?? ""
            name = name.count > 0 ? name : message.info.senderUserID
            nameLabel.text = name
        }
    }
}

extension MessageCell {
    @objc func longPressAction(_ longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            guard let message = messageVM else { return }
            delegate?.messageCell(self, longPressWith: message)
        }
    }
    
    @objc func selectButtonClick(_ sender: UIButton) {
        guard let message = messageVM else { return }
        message.isSelected = !message.isSelected
        selectIcon.image = loadImageSafely(
            with: message.isSelected
            ? "message_multiSelect_selected"
            : "message_multiSelect_normal")
    }
}

extension MessageCell :tapEmojiReactionViewDelegate {
    func onClickEmojiString(emoji: String) {
        if emoji.count > 0 {
            self.delegate?.onClickEmojiReaction(self, emoji: emoji)
        }
    }
}
