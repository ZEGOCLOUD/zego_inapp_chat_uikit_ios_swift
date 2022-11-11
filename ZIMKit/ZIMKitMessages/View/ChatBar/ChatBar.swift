//
//  ChatBar.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/10.
//

import Foundation

let chatTextViewTBMargin: CGFloat = 7
let chatTextViewLRMargin: CGFloat = 12.0
let textViewHeightMin: CGFloat = 35
let textViewHeightMax: CGFloat = 92.0

protocol ChatBarDelegate: AnyObject {
    /// trigger when chatbar status changed.
    func chatBar(_ chatBar: ChatBar, didChangeStatus status: ChatBarStatus)

    /// trigger when send button on keyboard clicked.
    func chatBar(_ chatBar: ChatBar, didSendText text: String)

    /// trigger when audio will send.
    func chatBar(_ chatBar: ChatBar, didSendAudioWith path: String, duration: UInt32)

    /// trigger when more function button clicked, photo or file.
    func chatBar(_ chatBar: ChatBar, didSelectMoreViewWith type: MoreFuncitonType)

    /// trigger when audio recorder start.
    func chatBar(_ chatBar: ChatBar, didStartToRecord recorder: AudioRecorder)

    /// when chat bar constraints changed, the message tableview should scroll to bottom.
    func chatBarDidUpdateConstraints(_ chatBar: ChatBar)

    /// the delete button will appear when status is `select`
    func chatBarDidClickDeleteButton(_ chatBar: ChatBar)
}

enum KeyboardType {
    case keyboard
    case emotion
    case funtion
}

/// The status of chatbar.
enum ChatBarStatus {
    /// The `normal` status, keyboard did hide.
    case normal

    /// The `keyboard` status, keyboard did show.
    case keybaord

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
    lazy var topContentView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints
        view.backgroundColor = .clear
        return view
    }()

    lazy var emotionButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "chat_face"), for: .normal)
        button.setImage(loadImageSafely(with: "chat_face_keybord"), for: .selected)
        button.addTarget(self, action: #selector(emotionButtonClick(_:)), for: .touchUpInside)
        return button
    }()

    lazy var addButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "chat_face_function"), for: .normal)
        button.setImage(loadImageSafely(with: "chat_face_function"), for: .selected)
        button.addTarget(self, action: #selector(addButtonClick(_:)), for: .touchUpInside)
        return button
    }()

    lazy var voiceButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "chat_face_voice"), for: .normal)
        button.setImage(loadImageSafely(with: "chat_face_keybord"), for: .selected)
        button.addTarget(self, action: #selector(voiceButtonClick(_:)), for: .touchUpInside)
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
        return textView
    }()


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

    var topContentHeightConstraint: NSLayoutConstraint!
    lazy var heightConstraint: NSLayoutConstraint! = {
        let heightConstraint = heightAnchor.pin(equalToConstant: height)
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

    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.layer.cornerRadius = 12.0
        button.setTitle(L10n("conversation_delete"), for: .normal)
        button.setTitleColor(.zim_textRed, for: .normal)
        button.setImage(loadImageSafely(with: "message_multiSelect_delete"), for: .normal)
        button.setImage(loadImageSafely(with: "message_multiSelect_delete"), for: .highlighted)
        button.backgroundColor = .zim_backgroundWhite
        button.isHidden = true
        button.addTarget(self, action: #selector(deleteButtonClick), for: .touchUpInside)
        return button
    }()

    override func setUp() {
        super.setUp()
        backgroundColor = .zim_backgroundWhite
        layer.shadowOffset = CGSize(width: 0, height: -2.0)
        layer.shadowColor = UIColor.zim_shadowBlack.withAlphaComponent(0.04).cgColor
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 8.0
        addNotifications()
        recorder.delegate = self
    }

    override func setUpLayout() {
        super.setUpLayout()

        addSubview(topContentView)
        topContentView.pin(anchors: [.leading, .trailing, .top], to: self)
        topContentHeightConstraint = topContentView.heightAnchor.pin(equalToConstant: height)
        topContentHeightConstraint.isActive = true

        topContentView.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.trailingAnchor.pin(
                equalTo: topContentView.trailingAnchor,
                constant: -12.0),
            addButton.bottomAnchor.pin(equalTo: topContentView.bottomAnchor, constant: -13.5)
        ])
        addButton.pin(to: 34)

        topContentView.addSubview(emotionButton)
        emotionButton.pin(anchors: [.centerY, .width, .height], to: addButton)
        emotionButton.trailingAnchor.pin(equalTo: addButton.leadingAnchor, constant: -12)
            .isActive = true

        topContentView.addSubview(voiceButton)
        voiceButton.pin(anchors: [.centerY, .width, .height], to: addButton)
        voiceButton.leadingAnchor.pin(
            equalTo: topContentView.leadingAnchor,
            constant: 12)
            .isActive = true

        topContentView.addSubview(chatTextView)
        NSLayoutConstraint.activate([
            chatTextView.leadingAnchor.pin(
                equalTo: voiceButton.trailingAnchor,
                constant: chatTextViewLRMargin),
            chatTextView.trailingAnchor.pin(
                equalTo: emotionButton.leadingAnchor,
                constant: -chatTextViewLRMargin),
            chatTextView.topAnchor.pin(
                equalTo: topContentView.topAnchor,
                constant: chatTextViewTBMargin),
            chatTextView.bottomAnchor.pin(
                equalTo: topContentView.bottomAnchor,
                constant: -chatTextViewTBMargin)
        ])

        topContentView.addSubview(recordButton)
        recordButton.pin(to: chatTextView)

        addSubview(faceView)
        faceView.pin(anchors: [.leading, .trailing, .bottom], to: self)
        faceView.topAnchor.pin(equalTo: topContentView.bottomAnchor).isActive = true

        addSubview(moreView)
        moreView.pin(anchors: [.leading, .trailing, .bottom], to: self)
        moreView.topAnchor.pin(equalTo: topContentView.bottomAnchor).isActive = true

        addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.pin(equalTo: topAnchor, constant: 8.5),
            deleteButton.leadingAnchor.pin(equalTo: leadingAnchor, constant: 16),
            deleteButton.trailingAnchor.pin(equalTo: trailingAnchor, constant: -16),
            deleteButton.heightAnchor.pin(equalToConstant: 44)
        ])
    }

    deinit {
        removeNotifications()
    }


    fileprivate(set) var status: ChatBarStatus = .normal {
        didSet {
            chatBarStatusDidChanged()
        }
    }

    weak var delegate: ChatBarDelegate?

    var keyboardFrame: CGRect = CGRect(x: 0, y: 10000, width: 0, height: 0)
    var keyboardAnimationDuration: Double = 0.25

    private var textViewHeight: CGFloat = textViewHeightMin
    private var height: CGFloat {
        let contentHeight = textViewHeight + (chatTextViewTBMargin + textViewTBMargin) * 2
        var height = contentHeight
        // use the default height, when status is `voice`
        if status == .voice {
            height -= textViewHeight
            height += textViewHeightMin
        }
        switch status {
        case .normal, .voice, .select:
            height += safeAreaInsets.bottom
        case .keybaord:
            height += keyboardFrame.height
        case .emotion:
            height += 250 + safeAreaInsets.bottom
        case .function:
            height += 109 + safeAreaInsets.bottom
        }
        return height
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
        /// and update the chatbar height.
        let textView = chatTextView.textView
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: textViewHeightMax))
        let oldHeight = textView.frame.height
        textViewHeight = size.height

        if textViewHeight > textViewHeightMax {
            textViewHeight = textViewHeightMax
        }

        if textViewHeight < textViewHeightMin {
            textViewHeight = textViewHeightMin
        }

        if oldHeight == textViewHeight { return }

        let topContentHeight = textViewHeight + (chatTextViewTBMargin + textViewTBMargin)  * 2
        topContentHeightConstraint.constant = topContentHeight
        updateChatBarConstraints()
    }

    // update my self's constraints
    func updateChatBarConstraints(_ animated: Bool = true) {
        self.heightConstraint.constant = self.height
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
}

extension ChatBar {
    @discardableResult
    override func resignFirstResponder() -> Bool {
        let r = super.resignFirstResponder()
        if status == .normal || status == .voice || status == .select { return r }
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
        case .normal, .keybaord, .function, .voice, .select:
            status = .emotion
        case .emotion:
            status = .keybaord
        }
    }

    @objc func addButtonClick(_ sender: UIButton) {
        if recorder.isRecording { return }
        switch status {
        case .normal, .emotion, .keybaord, .voice, .select:
            status = .function
        case .function:
            status = .keybaord
        }
    }

    @objc func voiceButtonClick(_ sender: UIButton) {
        if recorder.isRecording { return }
        switch status {
        case .normal, .keybaord, .emotion, .function, .select:
            status = .voice
        case .voice:
            status = .keybaord
        }
    }

    @objc func deleteButtonClick(_ sender: UIButton) {
        delegate?.chatBarDidClickDeleteButton(self)
    }
}

extension ChatBar {

    /// Update UI when status changed.
    func chatBarStatusDidChanged() {
        faceView.isHidden = status != .emotion
        moreView.isHidden = status != .function
        emotionButton.isSelected = status == .emotion
        voiceButton.isSelected = status == .voice
        chatTextView.isHidden = status == .voice
        recordButton.isHidden = status != .voice
        backgroundColor = (status == .voice || status == .select)
            ? .zim_backgroundGray1
            : .zim_backgroundWhite
        if status == .keybaord {
            chatTextView.textView.becomeFirstResponder()
        } else {
            chatTextView.textView.resignFirstResponder()
        }

        deleteButton.isHidden = status != .select
        addButton.isHidden = status == .select
        emotionButton.isHidden = status == .select
        voiceButton.isHidden = status == .select

        updateChatBarConstraints()
        delegate?.chatBar(self, didChangeStatus: status)
    }

    func clearTextViewInput() {
        chatTextView.textView.text = ""
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
        status = .keybaord
    }

    func textViewDidEndEditing(_ textView: UITextView) {

    }

    func textViewDidChange(_ textView: UITextView) {
        updateTextViewLayout()
        faceView.updateCurrentTextViewContent(textView.text)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView.text.isEmpty() { status = .normal }
            delegate?.chatBar(self, didSendText: textView.text)
            clearTextViewInput()
            return false
        }
        return true
    }

    func textViewDidChangeSelection(_ textView: UITextView) {

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
        delegate?.chatBar(self, didSendText: chatTextView.textView.text)
        clearTextViewInput()
    }
}

extension ChatBar: ChatBarMoreViewDelegate {
    func chatBarMoreView(_ moreView: ChatBarMoreView, didSelectItemWith type: MoreFuncitonType) {
        delegate?.chatBar(self, didSelectMoreViewWith: type)
    }
}
