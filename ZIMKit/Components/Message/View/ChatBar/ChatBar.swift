//
//  ChatBar.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/10.
//

import Foundation
import ZegoPluginAdapter

let textViewTopMargin: CGFloat = 5
let textViewBottomMargin: CGFloat = 5.0
let textViewHeightMin: CGFloat = 36
let textViewHeightMax: CGFloat = 92.0

let bottomBarHeight: CGFloat = 48.0

let chatViewTopMargin: CGFloat = 8

let bottomBarTopMargin: CGFloat = 6
let bottomBarDictionary: [String: [String: String]] = [
    "0": ["icon": "bottom_bar_audio_img", "title": "audio_title"],
    "1": ["icon": "bottom_bar_emoji_img", "title": "emote_title"],
    "2": ["icon": "bottom_bar_photo_img", "title": "message_album"],
    "3": ["icon": "bottom_bar_camera_img", "title": "take_photo"],
    "4": ["icon": "bottom_bar_call_img", "title": "audio_video_call"],
    "5": ["icon": "bottom_bar_call_img", "title": "audio_video_call"],
    "6": ["icon": "bottom_bar_file_img", "title": "message_file"]
]

let chatViewReplyMessageHeight: CGFloat = 30
let chatViewDefaultHeight:CGFloat = 46

protocol ChatBarDelegate: AnyObject {
    /// trigger when chatBar status changed.
    func chatBar(_ chatBar: ChatBar, didChangeStatus status: ChatBarStatus)
    
    /// trigger when send button on keyboard clicked.
    func chatBar(_ chatBar: ChatBar, didSendText text: String)
    
    /// trigger when audio will send.
    func chatBar(_ chatBar: ChatBar, didSendAudioWith path: String, duration: UInt32)
    
    /// trigger when more function button clicked, photo or file.
    func chatBar(_ chatBar: ChatBar, didSelectMoreViewWith type: ZIMKitMenuBarButtonName,originMessage: ZIMKitMessage?)
    
    /// trigger when audio recorder start.
    func chatBar(_ chatBar: ChatBar, didStartToRecord recorder: AudioRecorder)
    
    /// when chat bar constraints changed, the message tableview should scroll to bottom.
    func chatBarDidUpdateConstraints(_ chatBar: ChatBar)
    
    /// the delete button will appear when status is `select`
    func chatBarDidClickDeleteButton(_ chatBar: ChatBar)
    
    func chatBarDidClickPartForward(_ chatBar: ChatBar)
    
    func chatBarDidClickMergeForward(_ chatBar: ChatBar)
    
    func chatBarDidClickFullScreenEnterButton(content:String,replyContent:String?,cursorPosition:Int?)
    
    func chatBar(_ chatBar: ChatBar, didReplyText text: String,originMessage: ZIMKitMessage)
    
    func chatBar(_ chatBar: ChatBar, didReplyAudio audioPath: String,originMessage: ZIMKitMessage,duration: UInt32)
    
}

enum KeyboardType {
    case keyboard
    case emotion
    case function
}

/// The status of chatBar.
enum ChatBarStatus {
    /// The `normal` status, keyboard did hide.
    case normal
    
    /// The `keyboard` status, keyboard did show.
    case keyboard
    
    /// The `emotion` status, emotion view did show, and can type emoji to textview.
    case emotion
    
    /// The `function` status, function buttons did show, and can take photo or file.
    case function
    
    /// The `voice` status, voice button did show, can hold on voice button to record.
    case voice
    
    /// The `select`status, delete button did show, can delete selected messages.
    case select
}

class ChatBar: _View {
    
    // MARK: - Top ContentView
    lazy var bottomBarView: UIStackView = {
        let view = UIStackView().withoutAutoresizingMaskConstraints
        view.backgroundColor = UIColor(hex: 0xF5F6F7)
        view.distribution = .equalSpacing
        view.alignment = .center
        view.layoutMargins = .init(top: 8, left: 36, bottom: 8, right: 36)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    lazy var emotionButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "bottom_bar_emoji_img"), for: .normal)
        button.setImage(loadImageSafely(with: "bottom_bar_emoji_img_sel"), for: .selected)
        button.addTarget(self, action: #selector(emotionButtonClick(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "chat_face_function"), for: .normal)
        button.setImage(loadImageSafely(with: "chat_face_function_selected"), for: .selected)
        button.addTarget(self, action: #selector(addButtonClick(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var voiceButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "bottom_bar_audio_img"), for: .normal)
        button.setImage(loadImageSafely(with: "bottom_bar_audio_img_sel"), for: .selected)
        button.addTarget(self, action: #selector(voiceButtonClick(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var imageButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "bottom_bar_photo_img"), for: .normal)
        button.setImage(loadImageSafely(with: "bottom_bar_photo_img"), for: .selected)
        button.addTarget(self, action: #selector(imageButtonClick(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var cameraButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "bottom_bar_camera_img"), for: .normal)
        button.setImage(loadImageSafely(with: "bottom_bar_camera_img"), for: .selected)
        button.addTarget(self, action: #selector(cameraButtonClick(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var audioVideoButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "bottom_bar_call_img"), for: .normal)
        button.setImage(loadImageSafely(with: "bottom_bar_call_img"), for: .selected)
        button.addTarget(self, action: #selector(audioVideoCallButtonClick(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var fileButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "bottom_bar_file_img"), for: .normal)
        button.setImage(loadImageSafely(with: "bottom_bar_file_img"), for: .selected)
        button.addTarget(self, action: #selector(fileButtonClick(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var recordButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.isHidden = true
        button.setTitleColor(.zim_textBlack1, for: .normal)
        button.setTitleColor(.zim_textBlack1, for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.layer.cornerRadius = 12.0
        button.layer.masksToBounds = true
        button.backgroundColor = .zim_backgroundWhite
        button.setTitle(L10n("message_audio_record_normal"), for: .normal)
        button.setTitle(L10n("message_audio_record_release_to_send"), for: .highlighted)
        
        // add targets
        button.addTarget(
            self, action: #selector(recordButton(started:)),
            for: .touchDown)
        button.addTarget(
            self, action: #selector(recordButton(ended:)),
            for: .touchUpInside)
        button.addTarget(
            self, action: #selector(recordButton(canceled:)),
            for: [.touchUpOutside, .touchCancel])
        button.addTarget(
            self, action: #selector(recordButton(dragEnter:)),
            for: .touchDragEnter)
        button.addTarget(
            self, action: #selector(recordButton(dragExit:)),
            for: .touchDragExit)
        return button
    }()
    
    lazy var chatTextView: ChatTextView = {
        let textView = ChatTextView().withoutAutoresizingMaskConstraints
        textView.textView.delegate = self
        textView.delegate = self
        textView.replyDelegate = self
        return textView
    }()
    
    var callList:[ZIMKitMenuBarButtonName] = []
    // MARK: - Function Views
    lazy var faceView: FaceManagerView = {
        let faceView = FaceManagerView().withoutAutoresizingMaskConstraints
        faceView.isHidden = true
        faceView.delegate = self
        return faceView
    }()
    
    lazy var moreView: ChatBarMoreView = {
        let moreView = ChatBarMoreView().withoutAutoresizingMaskConstraints
        moreView.delegate = self
        moreView.isHidden = true
        return moreView
    }()
    
    lazy var sendVoiceView: ZIMKitSendVoiceMessageView = {
        let view = ZIMKitSendVoiceMessageView().withoutAutoresizingMaskConstraints
        view.isHidden = true
        view.delegate = self
        return view
    }()
    
    var chatViewHeightHeightConstraint: NSLayoutConstraint!
    
    var sendVoiceTopConstraint: NSLayoutConstraint!
    var replyMessage:ZIMKitMessage?
    
    
    lazy var heightConstraint: NSLayoutConstraint! = {
        let heightConstraint = heightAnchor.pin(equalToConstant: contentViewHeight)
        heightConstraint.isActive = true
        return heightConstraint
    }()
    
    lazy var recorder: AudioRecorder = AudioRecorder()
    lazy var recorderView: RecordView = {
        let view = RecordView().withoutAutoresizingMaskConstraints
        if let window = UIApplication.key {
            window.addSubview(view)
            view.pin(anchors: [.top, .leading, .trailing], to: window)
            view.bottomAnchor.pin(
                equalTo: window.safeAreaLayoutGuide.bottomAnchor,
                constant: -61.0)
            .isActive = true
        }
        view.isHidden = true
        return view
    }()
    
    lazy var multipleView: ZIMKitMultipleChoiceView = {
        let view: ZIMKitMultipleChoiceView = ZIMKitMultipleChoiceView().withoutAutoresizingMaskConstraints
        view.isHidden = true
        view.delegate = self
        return view
    }()
    
    lazy var audioVideoCallView: ZIMKitBottomPopView = {
        let view: ZIMKitBottomPopView = ZIMKitBottomPopView(callList: callList)
        view.delegate = self
        return view
    }()
    var buttons: [ZIMKitMenuBarButtonName] = ZIMKit().imKitConfig.bottomConfig.smallButtons
    var moreButtons: [ZIMKitMenuBarButtonName] = ZIMKit().imKitConfig.bottomConfig.expandButtons

    
    weak var delegate: ChatBarDelegate?
    
    var keyboardFrame: CGRect = CGRect(x: 0, y: 10000, width: 0, height: 0)
    var keyboardAnimationDuration: Double = 0.25
    
    private var textViewHeight: CGFloat = textViewHeightMin
    private var chatViewHeight: CGFloat {
        return textViewHeight + textViewTopMargin + textViewBottomMargin
    }
    private var contentViewHeight: CGFloat {
        let contentHeight = chatViewHeight + chatViewTopMargin + (buttons.count > 0 ? (bottomBarTopMargin + bottomBarHeight) : 0)
        var height = contentHeight
        switch status {
        case .normal, .select:
            height += safeAreaInsets.bottom
        case .keyboard:
            height += keyboardFrame.height
        case .emotion:
            height += 250 + safeAreaInsets.bottom
        case .function:
            height += 246 + safeAreaInsets.bottom
        case .voice :
            height += 250 + safeAreaInsets.bottom
        }
        return height
    }
    
    convenience init(peerConversation: Bool = true) {
        self.init()
        if peerConversation == false {
            moreButtons.removeAll(where: { $0 == .voiceCall || $0 == .videoCall })
        }
        self.addCallListData()
    }
    
    override func setUp() {
        super.setUp()
        calculatedStackViewSpacing()
        backgroundColor = UIColor(hex: 0xF5F6F7)
        layer.shadowOffset = CGSize(width: 0, height: -2.0)
        layer.shadowColor = UIColor.zim_shadowBlack.withAlphaComponent(0.04).cgColor
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 8.0
        addNotifications()
        //        recorder.delegate = self
        
        addMoreViewDataSource()
    }
    
    func calculatedStackViewSpacing() {
        let maxCount: Int = ZIMKit().imKitConfig.bottomConfig.maxCount
        let screenWidth: CGFloat = UIScreen.main.bounds.size.width
        
        let totalFixedWidth = CGFloat(72) + CGFloat(32) * CGFloat(maxCount)
        let availableWidth = screenWidth - totalFixedWidth
        let divider = CGFloat(maxCount - 1)
        
        bottomBarView.spacing = CGFloat(availableWidth / divider)
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        
        addSubview(chatTextView)
        
        chatViewHeightHeightConstraint = chatTextView.heightAnchor.pin(equalToConstant: chatViewDefaultHeight)
        NSLayoutConstraint.activate([
            chatTextView.topAnchor.pin(equalTo: self.topAnchor, constant: chatViewTopMargin),
            chatTextView.leadingAnchor.pin(equalTo: self.leadingAnchor, constant: 8),
            chatTextView.trailingAnchor.pin(equalTo: self.trailingAnchor, constant: -8),
            chatViewHeightHeightConstraint
        ])
        chatViewHeightHeightConstraint.isActive = true
        
        if buttons.count > 0 {
            addSubview(bottomBarView)
            NSLayoutConstraint.activate([
                bottomBarView.topAnchor.pin(equalTo: chatTextView.bottomAnchor, constant: bottomBarTopMargin),
                bottomBarView.leadingAnchor.pin(equalTo: self.leadingAnchor, constant: 0),
                bottomBarView.trailingAnchor.pin(equalTo: self.trailingAnchor, constant: 0),
                bottomBarView.heightAnchor.pin(equalToConstant: bottomBarHeight)
            ])
            
            addStackViewSubviews()
            
            addSubview(faceView)
            faceView.pin(anchors: [.leading, .trailing, .bottom], to: self)
            faceView.topAnchor.pin(equalTo: bottomBarView.bottomAnchor).isActive = true
            
            addSubview(moreView)
            moreView.pin(anchors: [.leading, .trailing, .bottom], to: self)
            moreView.topAnchor.pin(equalTo: bottomBarView.bottomAnchor).isActive = true
            
            addSubview(sendVoiceView)
            sendVoiceView.pin(anchors: [.leading, .trailing, .bottom], to: self)
            
            sendVoiceTopConstraint = sendVoiceView.topAnchor.pin(equalTo: topAnchor,constant: 108)
            sendVoiceTopConstraint.isActive = true
        }
        
        addSubview(multipleView)
        NSLayoutConstraint.activate([
            multipleView.topAnchor.pin(equalTo: topAnchor, constant: 0),
            multipleView.leadingAnchor.pin(equalTo: leadingAnchor, constant: 0),
            multipleView.trailingAnchor.pin(equalTo: trailingAnchor, constant: 0),
            multipleView.bottomAnchor.pin(equalTo: bottomAnchor, constant: 0)
        ])
    }
    
    deinit {
        removeNotifications()
    }
    
    func addCallListData() {
        for (_, number) in moreButtons.enumerated() {
            if number == .voiceCall ||
                number == .videoCall {
                callList.append(number)
            }
        }
    }
    
    func addStackViewSubviews() {
        for (_, number) in buttons.enumerated() {
            if number == .audio {
                bottomBarView.addArrangedSubview(voiceButton)
            }
            if number == .emoji {
                bottomBarView.addArrangedSubview(emotionButton)
            }
            if number == .picture {
                bottomBarView.addArrangedSubview(imageButton)
            }
            if number == .takePhoto {
                bottomBarView.addArrangedSubview(cameraButton)
            }
            if number == .voiceCall ||
                number == .voiceCall {
                bottomBarView.addArrangedSubview(audioVideoButton)
            }
            if number == .file {
                bottomBarView.addArrangedSubview(fileButton)
            }
            
            if number == .expand {
                bottomBarView.addArrangedSubview(addButton)
            }
            // index = 3
            if bottomBarView.arrangedSubviews.count == ZIMKit().imKitConfig.bottomConfig.maxCount
                && buttons.count > ZIMKit().imKitConfig.bottomConfig.maxCount {
                //                bottomBarView.addArrangedSubview(addButton)
                //                addMoreViewDataSource()
                break
            }
        }
        
    }
    
    func addMoreViewDataSource() {
        
        for (_, number) in moreButtons.enumerated() {
            if number == .expand {
                continue
            }
            //            if  index >= (ZIMKit().imKitConfig.bottomConfig.maxCount - 1) {
            let stringValue = String(describing: number.rawValue)
            let dict:NSDictionary = bottomBarDictionary[stringValue]! as NSDictionary
            let model: ChatBarMoreModel = ChatBarMoreModel(icon: dict["icon"] as! String,
                                                           title: L10n(dict["title"] as! String),
                                                           type: number)
            
            self.moreView.dataSource.append(model)
            //            }
        }
        
        var containCall = false
        for (index, number) in self.moreView.dataSource.enumerated() {
            if (number.type == .videoCall || number.type == .voiceCall) && containCall == false {
                containCall = true
                continue
            }
            
            if (number.type == .videoCall ||
                number.type == .voiceCall) &&
                containCall == true {
                self.moreView.dataSource.remove(at: index)
            }
        }
    }
    
    fileprivate(set) var status: ChatBarStatus = .normal {
        didSet {
            chatBarStatusDidChanged()
        }
    }
    
    func replyMessage(fromUserName:String,content:String,originMessage: ZIMKitMessage) {
        replyMessage = originMessage
        chatTextView.replyingMessage = true
        updateTextViewLayout()
        chatTextView.didBeginReplyMessage(fromUserName: fromUserName, content: content)
        chatTextView.layoutSubviews()
    }
    
}

// MARK: - UI
extension ChatBar {
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        updateChatBarConstraints(false)
    }
    func updateTextViewLayout() {
        /// the textView height will change, when text changed
        /// and update the chatBar height.
        let textView = chatTextView.textView
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: textViewHeightMax))
        let oldHeight = textView.frame.height
        textViewHeight =  (textView.text.count > 0) ? size.height : textViewHeightMin
        
        if textViewHeight > textViewHeightMax {
            textViewHeight = textViewHeightMax
        }
        
        if textViewHeight < textViewHeightMin {
            textViewHeight = textViewHeightMin
        }
        if replyMessage != nil {
            textViewHeight += chatViewReplyMessageHeight + 12
        }
        if oldHeight == textViewHeight { return }
        
        let topContentHeight = textViewHeight + textViewTBMargin + textViewTBMargin
        
        NSLayoutConstraint.deactivate([chatViewHeightHeightConstraint!])
        
        chatViewHeightHeightConstraint = chatTextView.heightAnchor.constraint(equalToConstant:topContentHeight)
        chatViewHeightHeightConstraint.isActive = true
        chatTextView.layoutIfNeeded()
        updateChatBarConstraints()
    }
    
    // update my self's constraints
    func updateChatBarConstraints(_ animated: Bool = true) {
        self.heightConstraint.constant = self.contentViewHeight
        if status == .normal {
            self.addButton.isSelected = false
        }
        let block = { [weak self] in
            guard let self = self else { return }
            self.superview?.layoutIfNeeded()
            self.delegate?.chatBarDidUpdateConstraints(self)
        }
        guard animated else {
            block()
            return
        }
        UIView.animate(withDuration: keyboardAnimationDuration) {
            block()
        }
    }
    
    func replyMessageEnd() {
        replyMessage = nil
        chatTextView.cancelReplyState()
        clearTextViewInput()
    }
}

extension ChatBar {
    @discardableResult
    override func resignFirstResponder() -> Bool {
        let r = super.resignFirstResponder()
        if status == .normal || status == .select { return r }
        status = .normal
        return r
    }
    
    func enableMultiSelect(_ enable: Bool) {
        status = enable ? .select : .normal
    }
}

// MARK: - Actions
extension ChatBar {
    @objc func emotionButtonClick(_ sender: UIButton) {
        if recorder.isRecording { return }
        switch status {
        case .normal, .keyboard, .function, .voice, .select:
            status = .emotion
        case .emotion:
            status = .keyboard
        }
    }
    
    @objc func addButtonClick(_ sender: UIButton) {
        if recorder.isRecording { return }
        sender.isSelected = !sender.isSelected
        switch status {
        case .normal, .emotion, .keyboard, .voice, .select:
            status = .function
        case .function:
            status = .keyboard
        }
    }
    
    @objc func voiceButtonClick(_ sender: UIButton) {
        if recorder.isRecording { return }
        switch status {
        case .normal, .keyboard, .emotion, .function, .select:
            status = .voice
        case .voice:
            status = .keyboard
        }
    }
    
    @objc func imageButtonClick(_ sender: UIButton) {
        status = .normal
        delegate?.chatBar(self, didSelectMoreViewWith: .picture,originMessage: replyMessage)
    }
    
    @objc func cameraButtonClick(_ sender: UIButton) {
        status = .normal
        delegate?.chatBar(self, didSelectMoreViewWith: .takePhoto,originMessage: replyMessage)
    }
    
    @objc func fileButtonClick(_ sender: UIButton) {
        status = .normal
        delegate?.chatBar(self, didSelectMoreViewWith: .file,originMessage: replyMessage)
    }
    
    @objc func audioVideoCallButtonClick(_ sender: UIButton) {
        status = .normal
        if ZegoPluginAdapter.callPlugin != nil {
            audioVideoCallView.showView()
        } else {
            print("⚠️⚠️⚠️ callPlugin 不存在")
        }
    }
    
    func sendMessage() {
        if chatTextView.textView.text.isEmpty { status = .normal }
        if replyMessage == nil {
            delegate?.chatBar(self, didSendText: chatTextView.textView.text)
        } else {
            delegate?.chatBar(self, didReplyText: chatTextView.textView.text,originMessage: replyMessage ?? ZIMKitMessage())
        }
        clearTextViewInput()
    }
}

extension ChatBar {
    
    /// Update UI when status changed.
    func chatBarStatusDidChanged() {
        faceView.isHidden = status != .emotion
        moreView.isHidden = status != .function
        emotionButton.isSelected = status == .emotion
        voiceButton.isSelected = status == .voice
        sendVoiceView.isHidden = status != .voice
        //        recordButton.isHidden = status != .voice
        backgroundColor = (status == .voice || status == .select)
        ? .zim_backgroundGray1
        : UIColor(hex: 0xF5F6F7)
        if status == .keyboard {
            chatTextView.textView.becomeFirstResponder()
        } else {
            chatTextView.textView.resignFirstResponder()
        }
        
        multipleView.isHidden = status != .select
        bottomBarView.isHidden = status == .select
        chatTextView.isHidden = status == .select
        addButton.isSelected = status == .function
        updateChatBarConstraints()
        delegate?.chatBar(self, didChangeStatus: status)
    }
    
    func clearTextViewInput() {
        chatTextView.textView.text = ""
    }
    
    func insertTextAfterCursor(_ newCursorPosition:Int) {
        // 获取光标位置
        let selectedRange = chatTextView.textView.selectedRange
        let beginning = chatTextView.textView.beginningOfDocument
//        let cursorPosition = chatTextView.textView.position(from: beginning, offset: selectedRange.location)
        
        let newPosition = chatTextView.textView.position(from: beginning, offset: newCursorPosition)
        chatTextView.textView.selectedTextRange = chatTextView.textView.textRange(from: newPosition!, to: newPosition!)
        chatTextView.textView.selectedRange = NSRange(location: newCursorPosition, length: 0)
    }
}

extension ChatBar : voiceAndVideoCallDelegate {
    func didSelectedVoiceAndVideoCall(videoCall: Bool) {
        delegate?.chatBar(self, didSelectMoreViewWith: videoCall ? .videoCall : .voiceCall, originMessage: replyMessage)
    }
}

// MARK: - TextViewDelegate
extension ChatBar: TextViewDelegate {
    func textViewDeleteBackward(_ textView: TextView) {
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        status = .keyboard
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let newCursorPosition = textView.selectedRange.location
        
        updateTextViewLayout()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7.0  //行间距
        let fontSize: CGFloat = 15.0
        
        let attributedString = NSAttributedString(string: textView.text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize), NSAttributedString.Key.paragraphStyle: paragraphStyle])
        
        if let lang = textView.textInputMode?.primaryLanguage, lang == "zh-Hans" {
            if textView.markedTextRange == nil {
                textView.attributedText = attributedString
            } else {
                
            }
        } else {
            textView.attributedText = attributedString
        }
        
        faceView.updateCurrentTextViewContent(textView.text)
        chatTextView.placeholderLabel.isHidden = textView.text.count > 0 ? true : false
        chatTextView.sendButton?.isEnabled = textView.text.count > 0 ? true : false
        insertTextAfterCursor(newCursorPosition)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return true
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
    }
}

extension ChatBar: TextViewCancelReplyMessageDelegate {
    func chatTextCancelReplyMessage() {
        replyMessage = nil
        chatTextView.replyingMessage = false
        updateTextViewLayout()
        chatTextView.layoutSubviews()
    }
}

// MARK: - FaceManagerViewDelegate
extension ChatBar: FaceManagerViewDelegate {
    func faceViewDidSelectDefaultEmoji(_ emoji: String) {
        let textView = chatTextView.textView
        var selectedRange = textView.selectedRange
        // if the textView has not text, we can't use textStorage to replace the emoji.
        if !textView.hasText {
            textView.text = emoji
        } else {
            textView.textStorage.replaceCharacters(in: selectedRange, with: emoji)
            textViewDidChange(textView)
        }
        
        // update the selectedRange
        // the emoji must use the utf16 to count the NSRange length
        selectedRange = NSRange(location: selectedRange.location+emoji.utf16.count, length: 0)
        textView.selectedRange = selectedRange
        
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    func faceViewDidDeleteButtonClicked() {
        chatTextView.textView.deleteBackward()
    }
    
    func faceViewDidSendButtonClicked() {
        
        if replyMessage != nil {
            delegate?.chatBar(self, didReplyText: chatTextView.textView.text,originMessage: replyMessage!)
        } else {
            delegate?.chatBar(self, didSendText: chatTextView.textView.text)
        }
        clearTextViewInput()
    }
}

extension ChatBar: ChatBarMoreViewDelegate {
    func chatBarMoreView(_ moreView: ChatBarMoreView, didSelectItemWith type: ZIMKitMenuBarButtonName) {
        if type == .emoji {
            self.emotionButtonClick(UIButton())
        } else if type == .audio {
            self.voiceButtonClick(UIButton())
        } else if type == .voiceCall || type == .videoCall {
            if ZegoPluginAdapter.callPlugin != nil {
                self.audioVideoCallView.showView()
            } else {
                print("⚠️⚠️⚠️ callPlugin 不存在")
            }
        } else {
            delegate?.chatBar(self, didSelectMoreViewWith: type,originMessage: replyMessage)
        }
    }
}

extension ChatBar: textViewToolBarDelegate {
    func didClicksendMessage() {
        sendMessage()
    }
    
    func didClickFullScreenEnter() {
        status = .normal
        delegate?.chatBarDidClickFullScreenEnterButton(content: chatTextView.textView.text,replyContent: self.replyMessage != nil ? chatTextView.replyBriefView.replyBriefLabel.text : "",cursorPosition: chatTextView.textView.selectedRange.location)
    }
}


extension ChatBar: SendVoiceMessageDelegate {
    func chatBar(didStartToRecord recorder: AudioRecorder) {
        print("\(#function)")
        delegate?.chatBar(self, didStartToRecord: recorder)
        
        sendVoiceTopConstraint!.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
    }
    
    func chatBar(didCancelRecord recorder: AudioRecorder) {
        sendVoiceTopConstraint!.constant = 108
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.layoutIfNeeded()
        }
    }
    
    func chatBar(didSendAudioWith path: String, duration: UInt32) {
        sendVoiceTopConstraint!.constant = 108
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.layoutIfNeeded()
        }
        if replyMessage != nil {
            delegate?.chatBar(self, didReplyAudio: path,originMessage: replyMessage!,duration: duration)
        } else {
            delegate?.chatBar(self, didSendAudioWith: path, duration: duration)
        }
    }
}

extension ChatBar:conversationMultipleOperationDelegate {
    func didClickDeleteConversation() {
        delegate?.chatBarDidClickDeleteButton(self)
    }
    
    func didClickPartForwardConversation() {
        delegate?.chatBarDidClickPartForward(self)
    }
    
    func didClickMergeForwardConversation() {
        delegate?.chatBarDidClickMergeForward(self)
    }
}
