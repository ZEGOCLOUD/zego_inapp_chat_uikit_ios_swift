//
//  MessageAVPlayerViewController.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/15.
//

import Foundation
import AVKit

class MessageAVPlayerViewController: AVPlayerViewController, AVPlayerViewControllerDelegate {

    private(set) lazy var downloadButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setTitle(L10n("album_download_image"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .zim_backgroundBlue1
        button.layer.cornerRadius = 12.0
        button.addTarget(self, action: #selector(downloadButtonClick(_:)), for: .touchUpInside)
        return button
    }()

    private var messageVM: MessageViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        //        setupLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        player?.pause()
    }

    func setupLayout() {
        var contentView = view!
        if let contentOverlayView = contentOverlayView {
            contentView = contentOverlayView
        }
        contentView.addSubview(downloadButton)
        NSLayoutConstraint.activate([
            downloadButton.leadingAnchor.pin(equalTo: contentView.leadingAnchor, constant: 16.0),
            downloadButton.trailingAnchor.pin(equalTo: contentView.trailingAnchor, constant: -16.0),
            downloadButton.heightAnchor.pin(equalToConstant: 44.0),
            downloadButton.bottomAnchor.pin(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -8.5)
        ])
    }

    func setup(with messageVM: MessageViewModel) {
        self.messageVM = messageVM
        var url: URL?
        if FileManager.default.fileExists(atPath: messageVM.message.fileLocalPath) {
            url = URL(fileURLWithPath: messageVM.message.fileLocalPath)
        } else {
            url = URL(string: messageVM.message.fileDownloadUrl)
        }

        if let url = url {
            let player = AVPlayer(url: url)
            self.player = player
        }
    }

    func play() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        player?.play()
    }

    @objc func downloadButtonClick(_ sender: UIButton) {

    }
}
