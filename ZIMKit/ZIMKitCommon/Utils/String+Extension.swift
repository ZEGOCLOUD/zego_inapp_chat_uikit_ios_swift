//
//  String+Extension.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/22.
//

import Foundation

extension String {
    public func isEmpty() -> Bool {
        let set = CharacterSet.whitespacesAndNewlines
        let trimedStr = self.trimmingCharacters(in: set)
        return trimedStr.count == 0
    }
}
