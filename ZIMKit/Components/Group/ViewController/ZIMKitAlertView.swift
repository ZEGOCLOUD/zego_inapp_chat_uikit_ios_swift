//
//  ZIMKitAlertView.swift
//  ZIMKit
//
//  Created by zego on 2024/8/7.
//

import UIKit

class ZIMKitAlertView: UIView {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .zim_textBlack1
        label.textAlignment = .center
        label.text = L10n("add_member_title")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .zim_textBlack1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type:.system)
        button.setTitle(L10n("common_title_cancel"), for:.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(hex: 0x646A73), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let sureButton: UIButton = {
        let button = UIButton(type:.system)
        button.setTitle(L10n("common_sure"), for:.normal)
        button.setTitleColor(.black, for:.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(hex: 0x3478FC), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF1F4F8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var centerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF1F4F8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var titleString:String = ""
    var detailString:String = ""
    var buttonCount:[String] = [L10n("common_title_cancel"),L10n("common_sure")]
    var cancelBlock: (() -> Void)?
    var sureBlock: (() -> Void)?
    
    
    public init(title:String,detail:String,buttonCount:[String] ,cancelBlock: @escaping () -> Void, sureBlock: @escaping () -> Void) {
        super.init(frame:UIScreen.main.bounds)
        
        self.cancelBlock = cancelBlock
        self.sureBlock = sureBlock
        
        titleString = title
        detailString = detail
        self.buttonCount = buttonCount
        titleLabel.text = titleString
        detailLabel.text = detailString
        addSubviews()
    }
    
    func addSubviews() {
        backgroundColor = UIColor(hex: 0x000000, a: 0.4)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(cancelButton)
        containerView.addSubview(sureButton)
        containerView.addSubview(dividerView)
        containerView.addSubview(centerLine)
        containerView.addSubview(detailLabel)
        
        sureButton.isHidden = buttonCount.count != 2
        centerLine.isHidden = buttonCount.count != 2
        setupConstraints()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.addGestureRecognizer(tap)
        
        cancelButton.addTarget(self, action: #selector(cancelItemClick(_:)), for: .touchUpInside)
        sureButton.addTarget(self, action: #selector(sureItemClick(_:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.heightAnchor.pin(equalToConstant: (130.0) / 270.0 * (UIScreen.main.bounds.width - 106)),
            containerView.widthAnchor.pin(equalToConstant: UIScreen.main.bounds.width - 106),
            
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            cancelButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: ( buttonCount.count == 1) ? 1 : 0.5),
            cancelButton.heightAnchor.pin(equalToConstant: 50),
            
            sureButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            sureButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            sureButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: (buttonCount.count == 1) ? 1 : 0.5),
            sureButton.heightAnchor.pin(equalToConstant: 50),
            
            dividerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dividerView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            
            
            centerLine.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            centerLine.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            centerLine.widthAnchor.constraint(equalToConstant: 1),
            centerLine.heightAnchor.constraint(equalToConstant: 50),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 13),
            detailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            detailLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            detailLabel.heightAnchor.constraint(equalToConstant: 15),
        ])
    }
    
    func showView() {
        if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            self.alpha = 0
            keyWindow.addSubview(self)
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            } completion: { (finished) in
            }
        }
    }
    
    func hideView() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { (finished) in
            self.removeFromSuperview()
        }
    }
    
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.hideView()
    }
    
    @objc func cancelItemClick(_ button: UIButton) {
        self.hideView()
        self.cancelBlock?()
    }
    
    @objc func sureItemClick(_ button: UIButton) {
        if (self.sureBlock != nil) {
            self.hideView()
            self.sureBlock?()
            return
        }
    }
}

