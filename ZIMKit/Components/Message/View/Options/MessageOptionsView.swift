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
    
    func messageOptionsViewEmojiMessage(emoji:String,optionsView: MessageOptionsView)
}

class MessageOptionsView: _View {
    enum ContentType {
        case copy
        case speaker
        case delete
        //        case select
        case reply
        case forward
        case revoke
        case reaction
        case multipleChoice
    }
    
    struct Content {
        var icon: String
        var title: String
        var type: ContentType
    }
    
    var optionsViewMaxHeight: CGFloat = 153
    var optionsViewMinHeight: CGFloat = 124
    let emojiLineCount: CGFloat = 7.0
    let copyContent = Content(icon: "message_option_copy",title: L10n("message_option_copy"),type: .copy)
    
    var isSpeakerOff:Bool {
        return  UserDefaults.standard.bool(forKey: "is_message_speaker_off")
    }
    
    
    let replyContent = Content(icon: "message_option_reply",title: L10n("message_option_reply"),type: .reply)
    let forwardContent = Content(icon: "message_option_forward",title: L10n("message_option_forward"),type: .forward)
    let deleteContent = Content(icon: "message_option_delete",title: L10n("conversation_delete"),type: .delete)
    let revokeContent = Content(icon: "message_option_revoke",title: L10n("message_option_revoke"),type: .revoke)
    let reactionContent = Content(icon: "message_option_copy",title: L10n("message_option_copy"),type: .reaction)
    let multipleChoiceContent = Content(icon: "message_option_select",title: L10n("message_multi_select"),type: .multipleChoice)
    
    var contentsDict: [Int: Content] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let icon = isSpeakerOff ? "message_option_speaker" : "message_option_receiver"
        let title = isSpeakerOff ? "message_option_speaker_on" : "message_option_speaker_off"
        let speakerContent = Content(icon: icon,title: L10n(title),type: .speaker)
        
        let contents = [copyContent, replyContent, forwardContent, revokeContent, reactionContent, deleteContent,speakerContent, multipleChoiceContent]
        contentsDict = contents.enumerated().reduce(into: [Int: Content]()) { result, element in
            result[element.offset] = element.element
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = .init(width: 50, height: 56)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 2
        //        layout.sectionInset = .init(top: 58, left: 7, bottom: 17, right: 7)
        layout.scrollDirection = .vertical
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout).withoutAutoresizingMaskConstraints
            .withoutAutoresizingMaskConstraints
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.register(MessageOptionsCell.self,
                                forCellWithReuseIdentifier: MessageOptionsCell.reuseId)
        return collectionView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8.0
        return view
    }()
    
    lazy var lineView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = UIColor(hex: 0xFFFFFF, a: 0.2)
        return view
    }()
    
    lazy var faceView: EmojiReplyView = {
        let faceView = EmojiReplyView(frame: .zero, fullEmoji: false)
        faceView.backgroundColor = UIColor.clear
        faceView.delegate = self
        return faceView
    }()
    
    lazy var fullFaceView: EmojiReplyView = {
        let faceView = EmojiReplyView(frame: .zero, fullEmoji: true)
        faceView.backgroundColor = UIColor.clear
        faceView.isHidden = true
        faceView.delegate = self
        return faceView
    }()
    
    lazy var pageControl: UIPageControl = {
        let page = UIPageControl()
        page.backgroundColor = UIColor.clear
        page.currentPage = 0
        page.numberOfPages = Int(ceilf(Float(ZIMKit().imKitConfig.bottomConfig.emojis.count) / 14.0))
        page.currentPageIndicatorTintColor = UIColor(hex: 0x7F7F7F)
        page.pageIndicatorTintColor = UIColor(hex: 0xAAAAAA)
        page.isHidden = true
        return page
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
        contentView.addSubview(collectionView)
        //        contentView.embed(collectionView)
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
    /*
     语音：听筒/扬声器播放、回复、转发、多选、删除、撤回（仅自己发送可撤回）
     文本：复制、回复、转发、多选、删除、撤回（仅自己发送可撤回）
     所有文件类型&视频：回复、转发、多选、删除、撤回（仅自己发送可撤回）
     */
    func show(with targetView: UIView, messageVM: MessageViewModel) {
        self.messageVM = messageVM
        let message = messageVM.message
        if isSpeakerOff {
            optionsViewMinHeight += 10
            optionsViewMaxHeight += 10
        }
        dataSource.removeAll()
        
        var isRevoke = false
        let overtime:Bool = isTimestampMoreThanTwoMinutesOld(timestamp: messageVM.message.info.timestamp)
        if overtime == false && messageVM.message.info.senderUserID == ZIMKit.localUser?.id  && messageVM.message.info.sentStatus == .sendSuccess {
            isRevoke = true
        }
        var currentMessageConfig = [ZIMKitMessageOperationName]()
        
        switch message.type {
        case .text:
            currentMessageConfig = ZIMKit().imKitConfig.messageConfig.textMessageConfig.operations
        case .image:
            currentMessageConfig = ZIMKit().imKitConfig.messageConfig.imageMessageConfig.operations
        case .audio:
            currentMessageConfig = ZIMKit().imKitConfig.messageConfig.audioMessageConfig.operations
        case .video:
            currentMessageConfig = ZIMKit().imKitConfig.messageConfig.videoMessageConfig.operations
        case .file:
            currentMessageConfig = ZIMKit().imKitConfig.messageConfig.fileMessageConfig.operations
        case .combine:
            currentMessageConfig = ZIMKit().imKitConfig.messageConfig.combineMessageConfig.operations
            
        default:
            print("---")
        }
        
        for (_,menuName) in currentMessageConfig.enumerated() {
            if let content = contentsDict[menuName.rawValue] {
                if menuName == .revoke {
                    if isRevoke == true {
                        dataSource.append(content)
                    }
                } else if menuName != .reaction {
                    dataSource.append(content)
                }
            }
        }
        
        collectionView.reloadData()
        
        
        let rect = targetView.convert(targetView.bounds, to: self)
        let h = currentMessageConfig.contains(.reaction) ? optionsViewMinHeight : 76
        let w = emojiLineCount * (38.0 + 8.0) - 8.0 + 40.0
        var x = rect.midX - w / 2.0
        var y = 0.0
        let margin = 15.0
        
        let indicatorW = 14.0
        let indicatorH = 6.5
        let indicatorX = rect.midX - indicatorW / 2.0
        var indicatorY = 0.0
        
        // options view on the top of cell
        if rect.minY - CGFloat(max(optionsViewMaxHeight, optionsViewMinHeight)) - safeAreaInsets.top - margin > 0 {
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
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.pin(equalTo: contentView.topAnchor, constant: currentMessageConfig.contains(.reaction) ? 60.0: 10),
            collectionView.bottomAnchor.pin(equalTo: contentView.bottomAnchor, constant: -17.0),
            collectionView.leadingAnchor.pin(equalTo: contentView.leadingAnchor, constant: 7),
            collectionView.trailingAnchor.pin(equalTo: contentView.trailingAnchor, constant: -7)
        ])
        
        if currentMessageConfig.contains(.reaction) {
            lineView.frame = CGRect(x: 16, y: 48, width: w - 32, height: 1)
            contentView.addSubview(lineView)
        }
        
        if currentMessageConfig.contains(.reaction) {
            faceView.frame = CGRect(x: 14, y: 10, width: w - 32, height: 28)
            contentView.addSubview(faceView)
            
            fullFaceView.frame = CGRect(x: 16, y: 58, width: w - 32, height: 64)
            contentView.addSubview(fullFaceView)
        }
        
        pageControl.frame = CGRect(x: 0, y: 58 + 64 + 10, width: w, height: 10)
        contentView.addSubview(pageControl)
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
    
    //MARK: 消息时间比较
    func isTimestampMoreThanTwoMinutesOld(timestamp: UInt64) -> Bool {
        let currentTimeInterval = Date().timeIntervalSince1970
        let timestampInSeconds = Double(timestamp) / 1000  // 假设时间戳是以毫秒为单位
        let timeDifference = currentTimeInterval - timestampInSeconds
        
        let twoMinutesInSeconds = 120
        return timeDifference > Double(twoMinutesInSeconds)
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

extension MessageOptionsView :MessageOptionsEmojiDelegate {
    func didSelectedEmoji(emoji: String) {
        delegate?.messageOptionsViewEmojiMessage(emoji: emoji, optionsView: self)
    }
    
    func didShowFullEmoji(unFold: Bool) {
        self.fullFaceView.isHidden = !unFold
        self.fullFaceView.fullEmoji = true
        self.contentView.frame.size.height = unFold ? optionsViewMaxHeight : optionsViewMinHeight
        if unFold {
            self.contentView.frame.origin.y -= 29
        } else {
            self.contentView.frame.origin.y += 29
        }
        collectionView.isHidden = unFold
        pageControl.isHidden = !unFold
    }
    
    func didScrollerPage(page: Int) {
        pageControl.currentPage = page
    }
}



protocol MessageOptionsEmojiDelegate: AnyObject {
    func didSelectedEmoji(emoji:String)
    func didShowFullEmoji(unFold:Bool)
    func didScrollerPage(page:Int)
}


class CustomFlowLayout: UICollectionViewFlowLayout {
    
    /// item 数组
    private lazy var allAttrs = [UICollectionViewLayoutAttributes]()
    // 行个数
    public lazy var row = 2
    // 列个数
    public lazy var column = 7
    /// 设置分页大小
    override public var collectionViewContentSize: CGSize {
        return CGSize(width: viewSize.width * CGFloat(ceil(Double(allAttrs.count) / Double(row * column))),
                      height: viewSize.height)
    }
    /// CollectionView Size
    private var viewSize: CGSize {
        return collectionView?.frame.size ?? .zero
    }
    
    // MARK: - 生命周期
    override init() {
        super.init()
        scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - 布局 Items
    override public func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        itemSize = CGSize(width: 27,
                          height: 27)
        let allItemWidth = (CGFloat(column) * itemSize.width)
        let padding = (collectionView.frame.width - allItemWidth) / CGFloat(column - 1)
        (0..<collectionView.numberOfItems(inSection: 0)).forEach { (i) in
            let curpage = CGFloat(i / (column * row)) * collectionView.frame.width
            let itemX = (itemSize.width + padding) * CGFloat(i % column) + curpage
            var itemY = (itemSize.height + 13) * CGFloat(i / column % row)
            if i % (row * column) < column {
                itemY += 3
            }else {
                itemY -= 3
            }
            let attrs = layoutAttributesForItem(at: IndexPath(item: i, section: 0))!
            attrs.frame = CGRect(x: itemX, y: itemY, width: itemSize.width, height: itemSize.height)
            allAttrs.append(attrs)
        }
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return allAttrs.filter { rect.contains($0.frame) }
    }
}


class EmojiReplyView: UIView {
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 18
        return layout
    }()
    
    lazy var customFlowLayout: CustomFlowLayout = {
        let layout:CustomFlowLayout = CustomFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 8
        layout.column = 7
        layout.row = 2
        layout.sectionFootersPinToVisibleBounds = false
        layout.sectionHeadersPinToVisibleBounds = false;
        return layout
    }()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: fullEmoji ? customFlowLayout : flowLayout)
            .withoutAutoresizingMaskConstraints
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
        collectionView.register(EmojiReplyCell.self,
                                forCellWithReuseIdentifier: EmojiReplyCell.reuseIdentifier)
        return collectionView
    }()
    
    var rowCellCount: Int = 7
    var fullEmoji:Bool = true {
        didSet{
            collectionView.isPagingEnabled = fullEmoji
            collectionView.isScrollEnabled = fullEmoji
        }
    }
    
    var delegate: MessageOptionsEmojiDelegate?
    public init(frame: CGRect,fullEmoji:Bool) {
        super.init(frame: frame)
        self.fullEmoji = fullEmoji
        backgroundColor = UIColor.clear
        addSubview(collectionView)
        collectionView.pin(anchors: [.leading, .trailing, .top,.bottom], to: self)
    }
    
    lazy var emojiList: [String] = ZIMKit().imKitConfig.bottomConfig.emojis
  
    lazy var fullEmojiList: [String] = {
        let originalList = ZIMKit().imKitConfig.bottomConfig.emojis
        let startIndex = originalList.index(originalList.startIndex, offsetBy: 6)
        return Array(originalList[startIndex...])
    }()
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func numberOfCellsInRow(collectionViewWidth: CGFloat, itemSize: CGSize, minimumInteritemSpacing: CGFloat, sectionInset: UIEdgeInsets) -> Int {
        let availableWidth = collectionViewWidth
        let minSpace = minimumInteritemSpacing
        let totalSpace = collectionViewWidth - CGFloat(itemSize.width)
        let space = max(minSpace, totalSpace / CGFloat(max(0, (totalSpace / minSpace).rounded(.down))))
        let occupiedWidth = itemSize.width + space
        let maxSubviews = Int(round(availableWidth / occupiedWidth))
        return maxSubviews
        
    }
}

extension EmojiReplyView:  UICollectionViewDataSource,
                           UICollectionViewDelegate,
                           UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return self.fullEmoji ? fullEmojiList.count : emojiList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiReplyCell.reuseIdentifier,
            for: indexPath) as? EmojiReplyCell else {
            return DefaultEmojiCollectionView()
        }
        cell.backgroundColor = .clear
        cell.emojiLabel.text =  self.fullEmoji ? fullEmojiList[indexPath.row] : emojiList[indexPath.row]
        if indexPath.item == (rowCellCount - 1) && self.fullEmoji == false {
            cell.emojiLabel.isHidden = true
            cell.unfoldButton.isHidden = false
            cell.unfoldButton.isSelected = false
        } else {
            cell.emojiLabel.isHidden = false
            cell.unfoldButton.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.fullEmoji {
            return CGSizeMake(27, 27);
        } else {
            return CGSize(width: 28, height: 28)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? EmojiReplyCell
        if cell != nil {
            cell!.unfoldButton.isSelected = !cell!.unfoldButton.isSelected
        }
        if indexPath.item == (rowCellCount - 1) && self.fullEmoji == false {
            delegate?.didShowFullEmoji(unFold: cell!.unfoldButton.isSelected)
        } else {
          if self.fullEmoji == true {
            delegate?.didSelectedEmoji(emoji: fullEmojiList[indexPath.row])
          } else {
            delegate?.didSelectedEmoji(emoji: emojiList[indexPath.row])
          }
        }
    }
    
    //MARK: scrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let num = (collectionView.contentOffset.x / frame.width)
        delegate?.didScrollerPage(page: Int(num))
    }
}
class EmojiReplyCell: _CollectionViewCell {
    static let reuseIdentifier = String(describing: EmojiReplyCell.self)
    
    lazy var emojiLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .black
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var unfoldButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.clipsToBounds = true
        button.setImage(loadImageSafely(with: "icon_expand"), for: .normal)
        button.setImage(loadImageSafely(with: "icon_packup"), for: .selected)
        button.isHidden = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override func setUp() {
        super.setUp()
        contentView.backgroundColor = .clear
        contentView.addSubview(emojiLabel)
        contentView.addSubview(unfoldButton)
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        let directionInsets = NSDirectionalEdgeInsets(
            top: 2,
            leading: 2,
            bottom: 2,
            trailing: 2)
        embed(emojiLabel,insets: directionInsets)
        embed(unfoldButton)
        unfoldButton.layer.cornerRadius = unfoldButton.w / 2
        
    }
    
    
}
