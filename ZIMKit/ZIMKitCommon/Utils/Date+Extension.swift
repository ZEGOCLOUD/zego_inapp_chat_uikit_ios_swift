//
//  Date+Extension.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/8.
//

import Foundation

extension Date {
    public func isToday() -> Bool {
        return NSCalendar.current.isDateInToday(self)
    }

    public func isYesterday() -> Bool {
        return NSCalendar.current.isDateInYesterday(self)
    }

    public func isThisYear() -> Bool {
        let nowComponents = NSCalendar.current.dateComponents([.year], from: Date())
        let selfComponents = NSCalendar.current.dateComponents([.year], from: self)
        return nowComponents.year == selfComponents.year
    }

    // if now is 8/9 16:00, and the other date is 8/2 17:00
    // the time interval is within 7days, but it still not one week
    public func withOneWeek() -> Bool {
        let timeInterval = Date().timeIntervalSince(self)
        if timeInterval > 24 * 3600 * 7 {
            return false
        }
        let nowComponents = NSCalendar.current.dateComponents([.weekday], from: Date())
        let selfComponents = NSCalendar.current.dateComponents([.weekday], from: self)
        return nowComponents.weekday != selfComponents.weekday
    }

}
