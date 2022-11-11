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

    private var message: VideoMessage?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        //        setupLayout()
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

    func setup(with message: VideoMessage) {
        self.message = message
        var url: URL?
        if FileManager.default.fileExists(atPath: message.fileLocalPath) {
            url = URL(fileURLWithPath: message.fileLocalPath)
        } else {
            url = URL(string: message.fileDownloadUrl)
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
