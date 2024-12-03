//
//  MediaImageReplyView.swift
//  ZIMKit
//
//  Created by zego on 2024/10/12.
//

import UIKit

class MediaImageReplyView: UIView {
    
    lazy var thumbnailImageView: AnimatedImageView = {
        let imageView = AnimatedImageView().withoutAutoresizingMaskConstraints
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        return imageView
    }()
    
    lazy var progressView: CircularProgressView = {
        let view = CircularProgressView().withoutAutoresizingMaskConstraints
        view.isHidden = true
        view.backgroundColor = UIColor(hex: 0x000000, a: 0.5)
        return view
    }()
    
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
        embed(thumbnailImageView)
        embed(progressView)
    }
    
    private func updateSubviewsConstraint() {
        
    }
    
    func updateContent(messageVM: MessageViewModel,isResize: Bool) {
        let message = messageVM.message
        
        let path = messageVM.message.imageContent.thumbnailDownloadUrl.count > 0
        ? messageVM.message.imageContent.thumbnailDownloadUrl
        : messageVM.message.fileLocalPath
        let maxSize = CGSize(
            width: messageVM.contentSize.width * 3,
            height: messageVM.contentSize.height * 3)
        let placeHolder = "chat_image_fail_bg"
        
        thumbnailImageView.loadImage(with: path, placeholder: placeHolder, maxSize: maxSize, isResize: isResize) { receivedSize, totalSize in
            if messageVM.message.info.sentStatus == .sendSuccess && messageVM.message.info.direction == .receive {
                self.progressView.isHidden = false
                self.progressView.progress = Double(receivedSize / totalSize)
                if receivedSize == totalSize {
                    self.progressView.isHidden = true
                    self.progressView.progress = 0.0
                }
            }
        } completionHandler: { [weak message] value in
            switch value {
            case .success:
                // remove the other caches.
                if path != message?.fileLocalPath,
                   let fileLocalPath = message?.fileLocalPath {
                    ImageCache.removeCache(for: fileLocalPath)
                }
            case .failure:
                break
            }
        }

        if let messageVM = messageVM as? ImageMessageViewModel {
            updateMessageProgress(messageVM: messageVM)
        } else if let messageVM = messageVM as? ReplyMessageViewModel {
            updateMessageProgress(messageVM: messageVM)
        }

    }
    
    func updateMessageProgress(messageVM: MediaMessageViewModel) {
        messageVM.$uploadProgress.bindOnce { [weak self] _ in
            if messageVM.message.info.direction == .send {
                if messageVM.message.info.sentStatus == .sending {
                    self?.progressView.isHidden = messageVM.uploadProgress >= 1.0 ? true : false
                    self?.progressView.progress = messageVM.uploadProgress
                } else {
                    self?.progressView.isHidden = true
                    self?.progressView.progress = 0.0
                }
            }
        }
    }
}

