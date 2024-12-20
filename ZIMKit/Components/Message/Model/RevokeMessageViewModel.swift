//
//  RevokeMessageViewModel.swift
//  ZIMKit
//
//  Created by zego on 2024/8/5.
//

import UIKit

class RevokeMessageViewModel: MessageViewModel {
    override init(with msg: ZIMKitMessage) {
        super.init(with: msg)
    }
    
    override var contentSize: CGSize {
        return CGSize(width: MessageCell_Custom_Max_Width, height: 35)
    }
}
