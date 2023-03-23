//
//  UnReadBubble.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/5.
//

import Foundation

class UnReadBubble: _View {
    lazy var label: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 9, weight: .regular)
        label.textColor = .zim_textWhite
        label.text = "12"
        label.sizeToFit()
        addSubview(label)
        return label
    }()

    override func setUp() {
        super.setUp()

        backgroundColor = .zim_backgroundRed
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
        isHidden = true
    }

    override func setUpLayout() {
        super.setUpLayout()

        embed(label)
    }

    func setNum(_ num: UInt32) {
        var str = String(num)
        if num > 99 {
            str = "99+"
        }
        label.text = str
        self.isHidden = num == 0
    }

}
