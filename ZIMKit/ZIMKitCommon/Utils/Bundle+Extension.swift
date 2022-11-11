//
//  Bundle+Extension.swift
//  ZIMKitConversation
//
//  Created by Kael Ding on 2022/8/4.
//

import Foundation

private class BundleIdentifyingClass {}

extension Bundle {
    static var ZIMKit: Bundle {
        #if COCOAPODS
        if let bundle = Bundle(for: BundleIdentifyingClass.self)
            .url(forResource: "ZIMKitResources", withExtension: "bundle")
            .flatMap(Bundle.init(url:)) {
            return bundle
        } else {
            return Bundle(for: BundleIdentifyingClass.self)
        }
        #elseif SWIFT_PACKAGE
        return Bundle.module
        #elseif STATIC_LIBRARY
        if let bundle = Bundle.main
            .url(forResource: "ZIMKitResources", withExtension: "bundle")
            .flatMap(Bundle.init(url:)) {
            return bundle
        } else {
            return Bundle(for: BundleIdentifyingClass.self)
        }
        #else
        return Bundle(for: BundleIdentifyingClass.self)
        #endif
    }
}
