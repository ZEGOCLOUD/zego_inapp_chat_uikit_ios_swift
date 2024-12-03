//
//  ChatReactionView.swift
//  ZIMKit
//
//  Created by zego on 2024/9/27.
//

import UIKit
import ZIM

protocol tapEmojiReactionViewDelegate: NSObjectProtocol {
    func onClickEmojiString(emoji:String)
}

class ChatReactionView: UIView {
    
    weak var delegate: tapEmojiReactionViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupView()
    }
    
    private func setupView() {
        
    }
    
    func setUpSubViews(reactions:[ZIMMessageReaction],maxWidth:CGFloat,userNames:[String],direction: ZIMMessageDirection) {
        if reactions.count <= 0 || userNames.count <= 0 {
          return
        }
        for (_,view) in self.subviews.enumerated() {
            if view is EmojiReactionView {
                view.removeFromSuperview()
            }
        }
      
        // 行数
        var lineNumber = 0
        var currentReactionWidth:CGFloat = 0.0
        let reactionPadding:CGFloat = 5.0
        for (index,reaction) in reactions.enumerated() {
            let view = EmojiReactionView().withoutAutoresizingMaskConstraints
            view.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(onTapEmoji(_:)))
            view.addGestureRecognizer(tap)
            addSubview(view)
            
            let userName:String = userNames[index]
            view.updateContent(content: reaction.reactionType ,sendUserName: userName)

            view.updateSubViewsColor(direction: direction)
            let nameSize = userName.boundingRect(with: CGSize(width: maxWidth, height: 15), options: .usesLineFragmentOrigin, attributes: [.font : UIFont.systemFont(ofSize: 12)], context: nil)

            var viewWidth = ceil(nameSize.width + 50)
            var addWidth:CGFloat = 0.0
            if currentReactionWidth + viewWidth > maxWidth {
                if currentReactionWidth == 0 {
                    viewWidth = maxWidth
                } else {
                    lineNumber += 1
                    addWidth = viewWidth + reactionPadding
                }
                currentReactionWidth = 0.0
            } else {
                addWidth = viewWidth + reactionPadding
            }
            
            NSLayoutConstraint.activate([
                view.topAnchor.pin(equalTo: topAnchor,constant: CGFloat(lineNumber * 30)),
                view.leadingAnchor.pin(equalTo: leadingAnchor,constant: currentReactionWidth),
                view.heightAnchor.pin(equalToConstant: 24),
                view.widthAnchor.pin(equalToConstant: viewWidth)
            ])
            currentReactionWidth += addWidth
        }
    }
    
    @objc func onTapEmoji(_ tap: UITapGestureRecognizer) {
        if tap.view != nil {
            guard let emojiView = tap.view as? EmojiReactionView else { return }

            let emoji = emojiView.contentLabel.text ?? ""
            delegate?.onClickEmojiString(emoji: emoji)
            
        }
    }
}
