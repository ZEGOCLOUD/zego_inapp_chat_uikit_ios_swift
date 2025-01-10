//
//  ZIMKitCore.swift
//  Pods-ZegoPlugin
//
//  Created by Kael Ding on 2022/12/8.
//

import Foundation

class ZIMKitLogUtil: NSObject {
    static let shared = ZIMKitLogUtil()
    var externalLogDelegate:ZIMKitLogDelegate?
    private override init() {}
    
    func registerZIMKitLogDelegate(_ delegate: ZIMKitLogDelegate) {
        externalLogDelegate = delegate
    }
    
    func logDebug(filter: String, file: String, funcName: String, line: Int, tag: Int, format: String, arguments: CVarArg...) {
        let message = String(format: format, arguments: arguments)
        let resultMsg = String(format: "%@, %@, %@, %d,%@", filter, file, funcName,line,message)
        
        if externalLogDelegate != nil {
            externalLogDelegate?.writeLog!(.Debug, msg: resultMsg)
        }else{
            print("[Debug] \(filter)-\(line) \(funcName) - \(message)")
        }
    }
    
    func logTraceInfo(filter: String, file: String, funcName: String, line: Int, tag: Int, format: String, arguments: CVarArg...) {
        let message = String(format: format, arguments: arguments)
        let resultMsg = String(format: "%@, %@, %d,%@", filter, funcName, line,message)
        
        if externalLogDelegate != nil {
            externalLogDelegate?.writeLog!(.Info, msg: resultMsg)
        }else{
            print("[Info] \(filter) -\(line) \(funcName) - \(message)")
        }
    }
    
    func logTraceWarning(filter: String, file: String, funcName: String, line: Int, tag: Int, format: String, arguments: CVarArg...) {
        let message = String(format: format, arguments: arguments)
        let resultMsg = String(format: "%@, %@, %@, %d,%@", filter, file, funcName,line,message)
        
        if externalLogDelegate != nil {
            externalLogDelegate?.writeLog!(.Warning, msg: resultMsg)
        }else{
            print("[Warning] \(filter) -\(line) \(funcName) - \(message)")
        }
    }
    
    func logTraceError(filter: String, file: String, funcName: String, line: Int, tag: Int, format: String, arguments: CVarArg...) {
        let message = String(format: format, arguments: arguments)
        let resultMsg = String(format: "%@, %@, %@, %d,%@", filter, file, funcName,line,message)
        
        if externalLogDelegate != nil {
            externalLogDelegate?.writeLog!(.Error, msg: resultMsg)
        }else{
            print("[Error] \(filter) -\(line) \(funcName) - \(message)")
        }
    }
}


func ZIMKitLogD(filterName: String, format: String, arguments: CVarArg...) {
    ZIMKitLogUtil.shared.logDebug(filter: filterName, file: #file, funcName: #function, line: #line, tag: 0, format: format, arguments: arguments)
}

func ZIMKitLogI(filterName: String, format: String, arguments: CVarArg...) {
    ZIMKitLogUtil.shared.logTraceInfo(filter: filterName, file: #file, funcName: #function, line: #line, tag: 1215, format: format, arguments: arguments)
}

func ZIMKitLogW(filterName: String, format: String, arguments: CVarArg...) {
    ZIMKitLogUtil.shared.logTraceWarning(filter: filterName, file: #file, funcName: #function, line: #line, tag: 1215, format: format, arguments: arguments)
}

func ZIMKitLogE(filterName: String, format: String, arguments: CVarArg...) {
    ZIMKitLogUtil.shared.logTraceError(filter: filterName, file: #file, funcName: #function, line: #line, tag: 1215, format: format, arguments: arguments)
}

