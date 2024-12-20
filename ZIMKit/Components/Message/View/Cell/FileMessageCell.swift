//
//  FileMessageCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/15.
//

import Foundation

protocol FileMessageDelegate: MessageCellDelegate {
    func fileMessageCell(_ cell: FileMessageCell, didClickImageWith message: FileMessageViewModel)
}

class FileMessageCell: MessageCell {
    override class var reuseId: String {
        String(describing: FileMessageCell.self)
    }
    
    lazy var iconImageView = UIImageView().withoutAutoresizingMaskConstraints
    
    lazy var titleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .zim_textBlack1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    lazy var sizeLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .zim_textBlack1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var fileContentView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundWhite
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()
    
    lazy var downloadingIndicator: UIActivityIndicatorView = {
        var style = UIActivityIndicatorView.Style.medium
        if #available(iOS 13.0, *) {
            style = .medium
        }
        let indicator = UIActivityIndicatorView(style: style).withoutAutoresizingMaskConstraints
        return indicator
    }()
    
    override var messageVM: MessageViewModel? {
        didSet {
            guard let messageVM = messageVM as? FileMessageViewModel else { return }
            messageVM.$isDownloading.bindOnce { [weak self] _ in
                // when callback, self.message maybe is another object.
                if self?.messageVM !== messageVM { return }
                self?.updateDownloadingIndicator(messageVM)
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        containerView.backgroundColor = .zim_backgroundWhite
        containerView.layer.cornerRadius = 8.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        containerView.addGestureRecognizer(tap)
        containerView.isUserInteractionEnabled = true
    }
    
    var fileTopConstraint: NSLayoutConstraint!
    var fileLeftConstraint: NSLayoutConstraint!
    
    override func setUpLayout() {
        super.setUpLayout()
        fileTopConstraint = fileContentView.leadingAnchor.pin(equalTo: containerView.leadingAnchor,constant: 0)
        fileLeftConstraint = fileContentView.topAnchor.pin(equalTo: containerView.topAnchor, constant: 0)
        
        updateSubviewsConstraint()
    }
    
    func updateSubviewsConstraint() {
        guard let messageModel = messageVM as? FileMessageViewModel else { return }
        
        containerView.addSubview(fileContentView)
        
        NSLayoutConstraint.activate([
            fileTopConstraint,
            fileLeftConstraint,
            fileContentView.widthAnchor.pin(equalToConstant: messageModel.contentMediaSize.width),
            fileContentView.heightAnchor.pin(equalToConstant: messageModel.contentMediaSize.height),
        ])
        fileTopConstraint.isActive = true
        fileLeftConstraint.isActive = true
        
        fileContentView.addSubview(iconImageView)
        iconImageView.pin(anchors: [.centerY], to: fileContentView)
        iconImageView.pin(to: 39)
        iconImageView.leadingAnchor.pin(
            equalTo: fileContentView.leadingAnchor,
            constant: 19.5)
        .isActive = true
        
        fileContentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.pin(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.pin(equalTo: fileContentView.trailingAnchor, constant: -23),
            titleLabel.topAnchor.pin(equalTo: fileContentView.topAnchor, constant: 11),
            titleLabel.heightAnchor.pin(equalToConstant: 21)
        ])
        
        fileContentView.addSubview(sizeLabel)
        NSLayoutConstraint.activate([
            sizeLabel.leadingAnchor.pin(equalTo: titleLabel.leadingAnchor),
            sizeLabel.trailingAnchor.pin(equalTo: fileContentView.trailingAnchor,constant: -23),
            sizeLabel.topAnchor.pin(equalTo: titleLabel.bottomAnchor, constant: 2),
            sizeLabel.heightAnchor.pin(equalToConstant: 16.5)
        ])
        
        fileContentView.addSubview(downloadingIndicator)
        downloadingIndicator.pin(anchors: [.centerX, .centerY], to: iconImageView)
        downloadingIndicator.pin(to: 24.0)
    }
    
    override func updateContent() {
        super.updateContent()
        
        guard let messageVM = messageVM as? FileMessageViewModel else { return }
        let message = messageVM.message
        
        titleLabel.text = message.fileName
        sizeLabel.text = FileInfoManager.getFileSizeName(message.fileSize)
        iconImageView.image = loadImageSafely(with: FileInfoManager.getFileExtensionIcon(message.fileName))
        
        updateDownloadingIndicator(messageVM)
        
        if message.reactions.count > 0 {
            if message.info.direction == .send {
                containerView.backgroundColor = UIColor(hex: 0x3478FC)
                fileContentView.layer.borderWidth = 0
            } else {
                containerView.backgroundColor = UIColor(hex: 0xFFFFFF)
                fileContentView.layer.borderColor = UIColor(hex: 0xEFF0F2).cgColor
                fileContentView.layer.borderWidth = 1
            }
            containerView.layer.cornerRadius = 12
            
            fileTopConstraint.constant = 10
            fileLeftConstraint.constant = 12
        } else {
            fileTopConstraint.constant = 0
            fileLeftConstraint.constant = 0
        }
        updateSubviewsConstraint()
    }
    
    private func updateDownloadingIndicator(_ messageVM: FileMessageViewModel) {
        if messageVM.isDownloading {
            downloadingIndicator.startAnimating()
        } else {
            downloadingIndicator.stopAnimating()
        }
    }
    
}

extension FileMessageCell {
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        guard let messageVM = messageVM as? FileMessageViewModel else { return }
        let delegate = delegate as? FileMessageDelegate
        delegate?.fileMessageCell(self, didClickImageWith: messageVM)
    }
}
