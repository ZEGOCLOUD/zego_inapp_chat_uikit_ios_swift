//
//  MediaReplyView.swift
//  Kingfisher
//
//  Created by zego on 2024/10/12.
//

import UIKit

class MediaVideoReplyView: UIView {
    
    lazy var progressView: CircularProgressView = {
        let view = CircularProgressView().withoutAutoresizingMaskConstraints
        view.isHidden = true
        view.backgroundColor = UIColor(hex: 0x000000, a: 0.5)
        return view
    }()
    
    lazy var videoImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var playImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.image = loadImageSafely(with: "message_video_play")
        imageView.layer.cornerRadius = 22.0
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var durationLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .zim_textWhite
        label.textAlignment = .right
        return label
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
        embed(videoImageView)
        embed(progressView)
        addSubview(playImageView)
        videoImageView.addSubview(durationLabel)
    }
    
    private func updateSubviewsConstraint() {
        
        NSLayoutConstraint.activate([
            durationLabel.trailingAnchor.pin(equalTo: videoImageView.trailingAnchor, constant: -8),
            durationLabel.bottomAnchor.pin(equalTo: videoImageView.bottomAnchor, constant: -5),
            durationLabel.heightAnchor.pin(equalToConstant: 14)
        ])
        
        playImageView.pin(anchors: [.centerX, .centerY], to: self)
        playImageView.pin(to: 44.0)
    }
    
    func updateContent(messageVM:MediaMessageViewModel) {
        
        let message = messageVM.message
        
        let placeHolder = "chat_image_fail_bg"
        let url = message.videoContent.firstFrameDownloadUrl.count > 0
        ? message.videoContent.firstFrameDownloadUrl
        : message.videoContent.firstFrameLocalPath
        
        if messageVM.message.info.direction == .receive {
            updateProgress(progress: 0.0)
        }
        videoImageView.loadImage(with: url, placeholder: placeHolder) { [weak self] receivedSize, totalSize in
            if messageVM.message.info.direction == .receive {
                self?.progressView.progress = CGFloat(receivedSize) / CGFloat(totalSize)
                if receivedSize == totalSize {
                    self?.endProgress()
                }
            }
        } completionHandler: { [weak self] value in
            switch value {
            case .success:
                print("")
            case .failure:
                break
            }
            self?.endProgress()
        }
        
        let min = message.videoContent.duration / 60
        let seconds = message.videoContent.duration % 60
        durationLabel.text = String(format: "%d:%02d", min, seconds)
        
        messageVM.$uploadProgress.bindOnce { [self] _ in
            if message.info.direction == .send {
                if message.info.sentStatus == .sending {
                    if messageVM.uploadProgress < 1.0 {
                        updateProgress(progress: messageVM.uploadProgress)
                    } else {
                        endProgress()
                    }
                } else {
                    endProgress()
                }
            }
        }
    }
    
    
    func updateProgress(progress:CGFloat) {
        progressView.isHidden = false
        playImageView.isHidden = true
        durationLabel.isHidden = true
        progressView.progress = progress
    }
    
    func endProgress() {
        self.progressView.isHidden = true
        self.playImageView.isHidden = false
        self.durationLabel.isHidden = false
        self.progressView.progress = 0.0
    }
}
