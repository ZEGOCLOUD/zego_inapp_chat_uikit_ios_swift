//
//  MessageOptionsView.swift
//  Kingfisher
//
//  Created by Kael Ding on 2022/9/26.
//

import Foundation

protocol MessageOptionsViewDelegate: AnyObject {
    func messageOptionsView(
        _ optionsView: MessageOptionsView,
        didSelectItemWith type: MessageOptionsView.ContentType)
}

class MessageOptionsView: _View {
    enum ContentType {
        case copy
        case speaker
        case delete
        case select
    }

    struct Content {
        var icon: String
        var title: String
        var type: ContentType
    }

    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = .init(width: 60, height: 60)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .vertical
        return layout
    }()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
            .withoutAutoresizingMaskConstraints
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(MessageOptionsCell.self,
                                forCellWithReuseIdentifier: MessageOptionsCell.reuseId)
        return collectionView
    }()

    lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8.0
        return view
    }()

    lazy var indicator = UIImageView()

    var messageVM: MessageViewModel!
    var dataSource: [Content] = []

    weak var delegate: MessageOptionsViewDelegate?

    override func setUp() {
        super.setUp()
        contentView.backgroundColor = .zim_backgroundBlack.withAlphaComponent(0.8)
    }

    override func setUpLayout() {
        super.setUpLayout()

        addSubview(contentView)
        addSubview(indicator)
        contentView.embed(collectionView)
    }

    override func updateContent() {
        super.updateContent()

    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if contentView.frame.contains(point) {
            return super.hitTest(point, with: event)
        }
        hide()
        return nil
    }

    func show(with targetView: UIView, messageVM: MessageViewModel) {
        self.messageVM = messageVM
        let message = messageVM.message
        
        dataSource.removeAll()
        if message.type == .text {
            dataSource.append(Content(
                                icon: "message_option_copy",
                                title: L10n("message_option_copy"),
                                type: .copy))
        }
        if message.type == .audio {
            let isSpeakerOff = UserDefaults.standard.bool(forKey: "is_message_speaker_off")
            let icon = isSpeakerOff ? "message_option_speaker" : "message_option_receiver"
            let title = isSpeakerOff ? "message_option_speaker_on" : "message_option_speaker_off"
            dataSource.append(Content(
                                icon: icon,
                                title: L10n(title),
                                type: .speaker))
        }
        dataSource.append(Content(
                            icon: "message_option_delete",
                            title: L10n("conversation_delete"),
                            type: .delete))
        dataSource.append(Content(
                            icon: "message_option_select",
                            title: L10n("message_multi_select"),
                            type: .select))

        collectionView.reloadData()


        let rect = targetView.convert(targetView.bounds, to: self)
        let h = 80.0
        let w = CGFloat(dataSource.count) * (60.0 + 8.0) - 8.0 + 20.0
        var x = rect.midX - w / 2.0
        var y = 0.0
        let margin = 15.0

        let indicatorW = 14.0
        let indicatorH = 6.5
        let indicatorX = rect.midX - indicatorW / 2.0
        var indicatorY = 0.0

        // options view on the top of cell
        if rect.minY - h - safeAreaInsets.top - margin > 0 {
            y = rect.minY - margin - h
            indicatorY = y + h
            indicator.image = loadImageSafely(with: "message_option_indicator_down")
        } else {
            y = rect.maxY + margin
            indicatorY = y - indicatorH
            indicator.image = loadImageSafely(with: "message_option_indicator_up")
        }

        if message.info.direction == .send {
            x = min(x, bounds.width - 8.0 - w)
        } else {
            x = max(x, 8.0)
        }

        contentView.frame = .init(x: x, y: y, width: w, height: h)
        indicator.frame = .init(x: indicatorX, y: indicatorY, width: indicatorW, height: indicatorH)

        contentView.alpha = 0.0
        indicator.alpha = 0.0
        Animate {
            self.contentView.alpha = 1.0
            self.indicator.alpha = 1.0
        }
    }

    func hide() {
        if superview == nil { return }
        Animate {
            self.contentView.alpha = 0.0
            self.indicator.alpha = 0.0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

extension MessageOptionsView: UICollectionViewDataSource,
                              UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MessageOptionsCell.reuseId,
            for: indexPath) as! MessageOptionsCell
        cell.setupContent(dataSource[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = dataSource[indexPath.row]
        delegate?.messageOptionsView(self, didSelectItemWith: content.type)
        hide()
    }
}
