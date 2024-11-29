//
//  String+Time.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/8.
//

import Foundation

public func timestampToConversationDateStr(_ timestamp: UInt64?) -> String {

    guard let timestamp = timestamp else { return "" }

    let msgDate = Date(timeIntervalSince1970: Double(timestamp/1000))

    var format = "yyyy-MM-dd"

    if msgDate.isToday() {
        format = "HH:mm"
    } else if msgDate.isYesterday() {
        return L10n("common_yesterday")
    } else if msgDate.withOneWeek() {
        format = "EEEE"
    } else if msgDate.isThisYear() {
        format = "MM-dd"
    }

    return stringFromDate(msgDate, with: format)
}

public func timestampToMessageDateStr(_ timestamp: UInt64) -> String {
    let msgDate = Date(timeIntervalSince1970: Double(timestamp/1000))

    if msgDate.isToday() {
        return stringFromDate(msgDate, with: "HH:mm")
    } else if msgDate.isYesterday() {
        return L10n("common_yesterday") + " " + stringFromDate(msgDate, with: "HH:mm")
    } else if msgDate.withOneWeek() {
        return stringFromDate(msgDate, with: "EEEE HH:mm")
    } else if msgDate.isThisYear() {
        return stringFromDate(msgDate, with: "MM-dd HH:mm")
    } else {
        return stringFromDate(msgDate, with: "yyyy-MM-dd HH:mm")
    }
}

private func stringFromDate(_ date: Date, with format: String) -> String {
    let dateFormatter = DateFormatter()
    let timeZone = TimeZone.current
    dateFormatter.timeZone = timeZone
    dateFormatter.dateStyle = .full
    dateFormatter.timeStyle = .full
    dateFormatter.dateFormat = format

    return dateFormatter.string(from: date)
}

public func zimKit_convertStringToDictionary(json:String) -> [String:AnyObject]? {
    if let data = json.data(using: String.Encoding.utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String:AnyObject]
        } catch let error as NSError {
            print(error)
        }
    }
    return nil
}

public func zimKit_convertDictToString(dict:[String:AnyObject]) -> String? {
  do {
      let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
      if let jsonString = String(data: jsonData, encoding:.utf8) {
        return jsonString
      }
  } catch {
      return nil
  }
  return nil
}
