//
//  CombineMessageCell.swift
//  ZIMKit
//
//  Created by zego on 2024/8/22.
//

import UIKit
import ZIM

protocol CombineMessageCellDelegate: MessageCellDelegate {
    func combineMessageCell(_ cell: CombineMessageCell, didClickWith message: CombineMessageViewModel)
}

class CombineMessageCell: MessageCell {
    
    override class var reuseId: String {
        String(describing: CombineMessageCell.self)
    }
    
    lazy var titleLB: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.text = L10n("group_message")
        label.textColor = .zim_textWhite
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    lazy var contentLB: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .zim_textWhite
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var splitView: UIView = {
        let view: UIView = UIView().withoutAutoresizingMaskConstraints
        view.clipsToBounds = true
        view.alpha = 0.7
        view.layer.cornerRadius = 2
        return view
    }()
    
    var contentLabelBottomConstraint: NSLayoutConstraint!
    
    override func setUp() {
        super.setUp()
        containerView.layer.cornerRadius = 12.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        containerView.addGestureRecognizer(tap)
        containerView.isUserInteractionEnabled = true
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        updateSubviewsConstraint()
    }
    
    private func updateSubviewsConstraint() {
        
        containerView.addSubview(splitView)
        containerView.addSubview(titleLB)
        containerView.addSubview(contentLB)
        contentLabelBottomConstraint = contentLB.bottomAnchor.pin(equalTo: containerView.bottomAnchor, constant: -10)
        NSLayoutConstraint.activate([
            splitView.leadingAnchor.pin(equalTo: containerView.leadingAnchor, constant: 12),
            splitView.topAnchor.pin(equalTo: containerView.topAnchor, constant: 13),
            splitView.heightAnchor.pin(equalToConstant: 16),
            splitView.widthAnchor.pin(equalToConstant: 2),
            
            titleLB.leadingAnchor.pin(equalTo: splitView.trailingAnchor, constant: 8),
            titleLB.trailingAnchor.pin(equalTo: containerView.trailingAnchor, constant: -8),
            titleLB.centerYAnchor.pin(equalTo: splitView.centerYAnchor, constant: 0),
            titleLB.heightAnchor.pin(equalToConstant: 22),
            
            contentLB.leadingAnchor.pin(equalTo: containerView.leadingAnchor, constant: 12),
            contentLB.trailingAnchor.pin(equalTo: containerView.trailingAnchor, constant: -12),
            contentLB.topAnchor.pin(equalTo: titleLB.bottomAnchor, constant: 6),
            contentLabelBottomConstraint
        ])
        contentLabelBottomConstraint.isActive = true
        
    }
    
    override func updateContent() {
        super.updateContent()
        guard let messageVM = messageVM as? CombineMessageViewModel else { return }
        
        contentLB.attributedText = messageVM.attributedContent
        if messageVM.message.zim is ZIMCombineMessage {
            let combineMessage: ZIMCombineMessage = messageVM.message.zim as! ZIMCombineMessage
            titleLB.text = combineMessage.title
        }
        if messageVM.message.info.direction == .send {
            containerView.backgroundColor = UIColor(hex: 0x3478FC)
            titleLB.textColor = .zim_textWhite
            splitView.backgroundColor = .zim_backgroundWhite
        } else {
            containerView.backgroundColor = .zim_backgroundWhite
            titleLB.textColor = .zim_textBlack1
            splitView.backgroundColor = UIColor(hex: 0x2A2A2A)
        }
        if messageVM.message.reactions.count <= 0 {
            contentLabelBottomConstraint.constant = -10.0
        } else {
            contentLabelBottomConstraint.constant = -(10.0 + messageVM.reactionHeight + 10.0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
extension CombineMessageCell {
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        guard let messageVM = messageVM as? CombineMessageViewModel else { return }
        let delegate = delegate as? CombineMessageCellDelegate
        delegate?.combineMessageCell(self, didClickWith: messageVM)
    }
}
