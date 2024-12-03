//
//  FileInfoManager.swift
//  ZIMKit
//
//  Created by zego on 2024/10/12.
//

import UIKit

class FileInfoManager: NSObject {
    static func getFileSizeName(_ size: Int64) -> String {
        if size < 1024 {
            return String(size) + " B"
        } else if size < 1024 * 1024 {
            return String(format: "%.2f", Double(size)/1024.0) + " KB"
        } else if size < 1024 * 1024 * 1024 {
            return String(format: "%.2f", Double(size)/1024.0/1024.0) + " MB"
        } else if size < 1024 * 1024 * 1024 * 1024 {
            return String(format: "%.2f", Double(size)/1024.0/1024.0/1024.0) + " GB"
        }
        return "0 B"
    }
    
    static func getFileExtensionIcon(_ path: String) -> String {
        
        let excelArray = ["xlsx", "xlsm", "xlsb", "xltx", "xltm", "xls", "xlt", "xls", "xml", "xlr", "xlw", "xla", "xlam"]
        let zipArray = ["rar", "zip", "arj", "gz", "arj", "z"]
        let wordArray = ["doc", "docx", "rtf", "dot", "html", "tmp", "wps"]
        let pptArray = ["ppt", "pptx", "pptm"]
        let pdfArray = ["pdf"]
        let txtArray = ["txt"]
        let videoArray =  ["mp4", "m4v", "mov", "qt", "avi", "flv", "wmv", "asf", "mpeg", "mpg", "vob", "mkv", "asf", "rm", "rmvb", "vob", "ts", "dat","3gp","3gpp","3g2","3gpp2","webm"]
        let audioArrary = ["mp3", "wma", "wav", "mid", "ape", "flac", "ape", "alac","m4a"]
        let picArrary = ["tiff", "heif", "heic", "jpg", "jpeg", "png", "gif", "bmp","webp"]
        let keyArrary = ["key"]

        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension.lowercased()
        
        if excelArray.contains(pathExtension) {
            return "file_icon_excel"
        } else if zipArray.contains(pathExtension) {
            return "file_icon_zip"
        } else if wordArray.contains(pathExtension) {
            return "file_icon_word"
        } else if pptArray.contains(pathExtension) {
            return "file_icon_ppt"
        } else if pdfArray.contains(pathExtension) {
            return "file_icon_pdf"
        } else if txtArray.contains(pathExtension) {
            return "file_icon_txt"
        } else if videoArray.contains(pathExtension) {
            return "file_icon_video"
        } else if audioArrary.contains(pathExtension) {
            return "file_icon_audio"
        } else if picArrary.contains(pathExtension) {
            return "file_icon_pic"
        } else if keyArrary.contains(pathExtension) {
            return "file_icon_keyNote"
        }
        
        return "file_icon_other"
    }
}
