//
//  Utils.swift
//  ZIMKitDemo
//
//  Created by Kael Ding on 2022/8/2.
//

import Foundation

func LocalizedStr(_ key : String, _ args: CVarArg...) -> String {
    let format = Bundle.main.localizedString(forKey: key, value: "", table: "Localizable")
    return String(format: format, args)
}
