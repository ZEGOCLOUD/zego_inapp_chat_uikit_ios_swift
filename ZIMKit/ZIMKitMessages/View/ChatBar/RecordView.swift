//
//  RecordView.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/7.
//

import Foundation

class RecordView: _View {

    enum Status {
        case normal
        case toBeCancelled
    }

    lazy var backgroundView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .zim_backgroundBlack.withAlphaComponent(0.5)
        return view
    }()

    lazy var bubbleView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.image = loadImageSafely(with: "voice_bubble")
        return imageView
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .zim_textBlack1
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.text = L10n("message_audio_record_stop", 10)
        return label
    }()

    lazy var voiceImageView: AnimatedImageView = {
        let imageView = AnimatedImageView().withoutAutoresizingMaskConstraints
        return imageView
    }()

    lazy var bottomLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .zim_textGray1
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.text = L10n("message_audio_record_tip1")
        return label
    }()

    override func setUp() {
        super.setUp()

    }

    override func setUpLayout() {
        super.setUpLayout()

        embed(backgroundView)

        addSubview(bubbleView)
        bubbleView.pin(anchors: [.width], to: 175)
        bubbleView.pin(anchors: [.centerX], to: self)
        bubbleView.bottomAnchor.pin(
            equalTo: bottomAnchor,
            constant: -32)
            .isActive = true

        bubbleView.addSubview(voiceImageView)
        bubbleView.addSubview(timeLabel)
        bubbleView.addSubview(bottomLabel)

        voiceImageView.pin(anchors: [.centerX], to: bubbleView)
        voiceImageView.pin(anchors: [.width], to: 98.0)
        voiceImageView.pin(anchors: [.height], to: 29.0)
        voiceImageView.topAnchor.pin(
            equalTo: bubbleView.topAnchor,
            constant: 27)
            .isActive = true

        timeLabel.pin(anchors: [.centerX, .centerY], to: voiceImageView)
        NSLayoutConstraint.activate([
            timeLabel.leadingAnchor.pin(equalTo: bubbleView.leadingAnchor, constant: 12),
            timeLabel.trailingAnchor.pin(equalTo: bubbleView.trailingAnchor, constant: -12)
        ])

        bottomLabel.pin(anchors: [.centerX], to: bubbleView)
        let attributed: [NSAttributedString.Key: AnyObject] = [.font : bottomLabel.font]
        let size = bottomLabel.text?.boundingRect(with: CGSize(width: 151, height: 1000), options: .usesLineFragmentOrigin, attributes: attributed, context: nil).size
        var h = size?.height ?? 16.0
        h = max(h, 16.0)
        NSLayoutConstraint.activate([
            bottomLabel.leadingAnchor.pin(equalTo: bubbleView.leadingAnchor, constant: 12),
            bottomLabel.trailingAnchor.pin(equalTo: bubbleView.trailingAnchor, constant: -12),
            bottomLabel.topAnchor.pin(
                equalTo: voiceImageView.bottomAnchor,
                constant: 12),
            bottomLabel.bottomAnchor.pin(
                equalTo: bubbleView.bottomAnchor,
                constant: -19),
            bottomLabel.heightAnchor.pin(equalToConstant: h)
        ])
    }

    override func updateContent() {
        super.updateContent()

        setAnimationStatus(status: .normal)
    }

    func show() {
        isHidden = false
        setAnimationStatus(status: .normal)
        timeLabel.isHidden = true
        voiceImageView.isHidden = false
    }

    func hide() {
        isHidden = true
    }

    func setBottomText(_ text: String) {
        bottomLabel.text = text
    }

    func setRemainTimeSeconds(_ seconds: Int) {
        timeLabel.text = L10n("message_audio_record_stop", seconds)
        timeLabel.isHidden = false
        voiceImageView.isHidden = true
    }

    func setAnimationStatus(status: Status) {
        let imageName = status == .normal ? "sound_level_blue" : "sound_level_red"
        guard let path = Bundle.ZIMKit.path(
                forResource: imageName,
                ofType: "gif") else { return }
        voiceImageView.animated(withPath: path)
    }
}
