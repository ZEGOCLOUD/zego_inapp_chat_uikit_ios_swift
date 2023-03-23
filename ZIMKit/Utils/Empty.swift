//
//  Empty.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/2/23.
//

import Foundation

protocol Empty {
    associatedtype T
    var isEmpty: Bool { get }
    var itself: T { get }
}

extension String: Empty {
    typealias T = String
    var isEmpty: Bool {
        let set = CharacterSet.whitespacesAndNewlines
        let trimedStr = self.trimmingCharacters(in: set)
        return trimedStr.count == 0
    }
    var itself: T {
        self
    }
}

extension CGSize: Empty {
    typealias T = CGSize
    var isEmpty: Bool {
        equalTo(.zero)
    }
    var itself: T {
        self
    }
}

extension Int: Empty {
    typealias T = Int
    var isEmpty: Bool {
        self == 0
    }
    var itself: T {
        self
    }
}

extension Int64: Empty {
    typealias T = Int64
    var isEmpty: Bool {
        self == 0
    }
    var itself: T {
        self
    }
}

extension UInt32: Empty {
    typealias T = UInt32
    var isEmpty: Bool {
        self == 0
    }
    var itself: T {
        self
    }
}
