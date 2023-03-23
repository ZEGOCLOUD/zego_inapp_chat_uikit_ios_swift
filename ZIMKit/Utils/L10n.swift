//
//  L10n.swift
//  ZIMKitCommon
//
//  Created by Kael Ding on 2022/8/2.
//

import Foundation

public func L10n(_ key : String, tableName: String = "ZIMKit", _ args: CVarArg...) -> String {
    let format = Bundle.ZIMKit.localizedString(forKey: key, value: "", table: tableName)
    return String(format: format, args)
}

