//
//  ZIMKitToast.swift
//  ZIMKit
//
//  Created by zego on 2024/7/26.
//

import UIKit

class ZIMKitToast: UIView {

    private let messageLabel: UILabel
    private let backgroundView: UIView

    init(message: String) {
        messageLabel = UILabel().withoutAutoresizingMaskConstraints
        backgroundView = UIView().withoutAutoresizingMaskConstraints

        super.init(frame: UIScreen.main.bounds)

        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 13)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        backgroundView.layer.cornerRadius = 10

        addSubview(backgroundView)
        backgroundView.addSubview(messageLabel)

        setupConstraints()

        DispatchQueue.main.asyncAfter(deadline:.now() + 2) { [weak self] in
            self?.removeFromSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.widthAnchor.constraint(equalToConstant: 190.0),
//            backgroundView.heightAnchor.constraint(equalToConstant: 40.0),
            backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),

            messageLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10),
            messageLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10),
            
            messageLabel.widthAnchor.constraint(lessThanOrEqualTo: backgroundView.widthAnchor, constant: -20),
            backgroundView.heightAnchor.constraint(equalTo: messageLabel.heightAnchor, constant: 20)

        ])
    }
}

