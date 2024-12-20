//
//  MediaFileReplyView.swift
//  ZIMKit
//
//  Created by zego on 2024/10/12.
//

import UIKit

class MediaFileReplyView: UIView {
    
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
        view.layer.borderColor = UIColor(hex: 0xEFF0F2).cgColor
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
    
    
    var messageVM: ReplyMessageViewModel? {
        didSet {
            if messageVM?.message.type == .file {
                messageVM?.$isDownloading.bindOnce { [self] _ in
                    self.updateDownloadingIndicator(messageVM!)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        addSubviews()
        updateSubviewsConstraint()
    }
    
    private func addSubviews() {
        self.embed(fileContentView)
        fileContentView.addSubview(iconImageView)
        fileContentView.addSubview(titleLabel)
        fileContentView.addSubview(sizeLabel)
        fileContentView.addSubview(downloadingIndicator)
    }
    
    private func updateSubviewsConstraint() {
        
        iconImageView.pin(anchors: [.centerY], to: fileContentView)
        iconImageView.pin(to: 39)
        iconImageView.leadingAnchor.pin(
            equalTo: fileContentView.leadingAnchor,
            constant: 19.5)
        .isActive = true
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.pin(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.pin(equalTo: fileContentView.trailingAnchor, constant: -23),
            titleLabel.topAnchor.pin(equalTo: fileContentView.topAnchor, constant: 11),
            titleLabel.heightAnchor.pin(equalToConstant: 21)
        ])
        
        NSLayoutConstraint.activate([
            sizeLabel.leadingAnchor.pin(equalTo: titleLabel.leadingAnchor),
            sizeLabel.trailingAnchor.pin(equalTo: fileContentView.trailingAnchor,constant: -23),
            sizeLabel.topAnchor.pin(equalTo: titleLabel.bottomAnchor, constant: 2),
            sizeLabel.heightAnchor.pin(equalToConstant: 16.5)
        ])
        
        downloadingIndicator.pin(anchors: [.centerX, .centerY], to: iconImageView)
        downloadingIndicator.pin(to: 24.0)
    }
    
    func updateContent(messageVM:ReplyMessageViewModel) {
        let message = messageVM.message
        titleLabel.text = message.fileName
        sizeLabel.text = FileInfoManager.getFileSizeName(message.fileSize)
        iconImageView.image = loadImageSafely(with: FileInfoManager.getFileExtensionIcon(message.fileName))
        
        updateDownloadingIndicator(messageVM)
        
        if message.info.direction == .receive {
            fileContentView.layer.borderWidth = 1.0
        } else {
            fileContentView.layer.borderWidth = 0.0
        }
    }
    
    private func updateDownloadingIndicator(_ messageVM: ReplyMessageViewModel) {
        if messageVM.isDownloading {
            downloadingIndicator.startAnimating()
        } else {
            downloadingIndicator.stopAnimating()
        }
    }
    
}
