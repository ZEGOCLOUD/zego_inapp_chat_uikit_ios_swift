//
//  UserInfo.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/9.
//

import Foundation

public class UserInfo {
    /// UserID: 1 to 32 characters, can only contain digits, letters, and the following special characters: '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '=', '-', '`', ';', '’', ',', '.', '<', '>', '/', '\'.
    public var id: String

    /// User name: 1 - 64 characters.
    public var name: String

    /// User avatar URL.
    public var avatarUrl: String?

    public init(_ userID: String, _ userName: String) {
        self.id = userID
        self.name = userName
    }
}
