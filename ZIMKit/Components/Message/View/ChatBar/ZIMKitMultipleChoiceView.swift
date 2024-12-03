//
//  ZIMKitMultipleChoiceView.swift
//  ZIMKit
//
//  Created by zego on 2024/8/21.
//

import UIKit
protocol conversationMultipleOperationDelegate: NSObjectProtocol {
    func didClickMergeForwardConversation()
    func didClickPartForwardConversation()
    func didClickDeleteConversation()
}

class ZIMKitMultipleChoiceView: UIView {
    
    weak var delegate: conversationMultipleOperationDelegate?
    
    lazy var mergeForwardButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "icon_forward_merge"), for: .normal)
        button.setTitle(L10n("forward_merge"), for: .normal)
        button.addTarget(self, action: #selector(mergeForwardButtonClick(_:)), for: .touchUpInside)
        button.setTitleColor(UIColor(hex: 0x646A73), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        button.tintColor = .clear
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = L10n("forward_merge")
            config.image = loadImageSafely(with: "icon_forward_merge")
            config.imagePlacement = .top
            config.imagePadding = 2
            button.configuration = config
            
        } else {
            button.frame.size.height = 50
            button.imageView?.frame = CGRectMake(0, 0, 28, 28)
            var spacing:CGFloat = 2.0
            
            var imageSize: CGSize = button.imageView!.frame.size
            var  titleSize: CGSize = button.titleLabel!.text!.size(withAttributes: [.font: UIFont.systemFont(ofSize: 11)])
            
            button.imageEdgeInsets = UIEdgeInsets(top: -titleSize.height - spacing, left: 0, bottom: 0, right: -titleSize.width);
            button.titleEdgeInsets = UIEdgeInsets(top: imageSize.height + spacing, left: -imageSize.width - (titleSize.width / 2.0) , bottom: 0, right: 0);
            
        }
        return button
    }()
    
    lazy var partForwardButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "icon_forward_part"), for: .normal)
        button.setTitle(L10n("forward_part"), for: .normal)
        button.addTarget(self, action: #selector(partForwardButtonClick(_:)), for: .touchUpInside)
        button.setTitleColor(UIColor(hex: 0x646A73), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        button.tintColor = .clear
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = L10n("forward_part")
            config.image = loadImageSafely(with: "icon_forward_part")
            config.imagePlacement = .top
            config.imagePadding = 2
            button.configuration = config
            
        } else {
            button.frame.size.height = 50
            button.imageView?.frame = CGRectMake(0, 0, 28, 28)
            
            var spacing:CGFloat = 2.0
            var imageSize: CGSize = button.imageView!.frame.size
            var  titleSize: CGSize = button.titleLabel!.text!.size(withAttributes: [.font: UIFont.systemFont(ofSize: 11)])
            
            button.imageEdgeInsets = UIEdgeInsets(top: -titleSize.height - spacing, left: 0, bottom: 0, right: -titleSize.width);
            button.titleEdgeInsets = UIEdgeInsets(top: imageSize.height + spacing, left: -imageSize.width - (titleSize.width / 2.0) , bottom: 0, right: 0);
            
        }
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom).withoutAutoresizingMaskConstraints
        button.setImage(loadImageSafely(with: "icon_delete"), for: .normal)
        button.setTitle(L10n("conversation_delete"), for: .normal)
        button.addTarget(self, action: #selector(deleteButtonClick(_:)), for: .touchUpInside)
        button.setTitleColor(UIColor(hex: 0x646A73), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        button.tintColor = .clear
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = L10n("conversation_delete")
            config.image = loadImageSafely(with: "icon_delete")
            config.imagePlacement = .top
            config.imagePadding = 2
            button.configuration = config
            
        } else {
            button.frame.size.height = 50
            button.imageView?.frame = CGRectMake(0, 0, 28, 28)
            
            var spacing:CGFloat = 2.0
            var imageSize: CGSize = button.imageView!.frame.size
            var titleSize: CGSize = button.titleLabel!.text!.size(withAttributes: [.font: UIFont.systemFont(ofSize: 11)])
            
            button.imageEdgeInsets = UIEdgeInsets(top: -titleSize.height - spacing, left: 0, bottom: 0, right: -titleSize.width);
            button.titleEdgeInsets = UIEdgeInsets(top: imageSize.height + spacing, left: -(imageSize.width + titleSize.width) , bottom: 0, right: 0);
            
        }
        return button
    }()
    
    
    lazy var contentSubView: UIStackView = {
        let view = UIStackView().withoutAutoresizingMaskConstraints
        view.backgroundColor = UIColor(hex: 0xF5F6F7)
        view.distribution = .equalSpacing
        view.alignment = .top
        view.layoutMargins = .init(top: 10, left: 50, bottom: 8, right: 50)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: 0xF5F6F7)
        setupSubViews()
        setupLayoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubViews() {
        addSubview(contentSubView)
        contentSubView.addArrangedSubview(mergeForwardButton)
        contentSubView.addArrangedSubview(partForwardButton)
        contentSubView.addArrangedSubview(deleteButton)
    }
    
    func setupLayoutConstraint() {
        
        NSLayoutConstraint.activate([
            contentSubView.topAnchor.pin(equalTo: topAnchor, constant: 0),
            contentSubView.leadingAnchor.pin(equalTo: leadingAnchor, constant: 0),
            contentSubView.trailingAnchor.pin(equalTo: trailingAnchor, constant: 0),
            contentSubView.bottomAnchor.pin(equalTo: bottomAnchor, constant: 0),
            mergeForwardButton.heightAnchor.constraint(equalToConstant: 50),
            partForwardButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    @objc func mergeForwardButtonClick(_ sender: UIButton) {
        delegate?.didClickMergeForwardConversation()
    }
    
    @objc func partForwardButtonClick(_ sender: UIButton) {
        delegate?.didClickPartForwardConversation()
    }
    
    @objc func deleteButtonClick(_ sender: UIButton) {
        delegate?.didClickDeleteConversation()
    }
    
}
