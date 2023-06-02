//
//  UIStackView+Extension.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/6/2.
//

import UIKit

extension UIStackView {
    @discardableResult
    public func setHStack(_ views: [UIView?]) -> Self {
        if self.axis != .horizontal {
            self.axis = .horizontal
        }
        self.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        views.forEach {
            if let view = $0 {
                self.addArrangedSubview(view)
            }
        }
        return self
    }
    
    @discardableResult
    public func setVStack(_ views: [UIView?]) -> Self {
        if self.axis != .vertical {
            self.axis = .vertical
        }
        self.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        views.forEach {
            if let view = $0 {
                self.addArrangedSubview(view)
            }
        }
        return self
    }
}
