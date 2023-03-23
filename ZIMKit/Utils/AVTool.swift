//
//  VideoTool.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/23.
//

import Foundation
import AVFoundation

class AVTool {
    
    struct VideoInfo {
        let image: UIImage?
        let duration: Double
    }
    
    static func getFirstFrameImageAndDuration(with videoUrl: URL) -> VideoInfo {
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey : false]
        let urlAsset = AVURLAsset(url: videoUrl, options: options)
        let duration = round(Double(urlAsset.duration.value) / Double(urlAsset.duration.timescale))
        let gen = AVAssetImageGenerator(asset: urlAsset)
        gen.appliesPreferredTrackTransform = true
        gen.maximumSize = UIScreen.main.bounds.size
        let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 30)

        if let imageRef = try? gen.copyCGImage(at: time, actualTime: nil) {
            return VideoInfo(image: UIImage(cgImage: imageRef), duration: duration)
        }
        return VideoInfo(image: nil, duration: 0)
    }
    
    static func getFirstFrameImageAndDuration(with videoPath: String) -> VideoInfo {
        let url = URL(fileURLWithPath: videoPath)
        return getFirstFrameImageAndDuration(with: url)
    }
    
    static func getDurationOfMediaFile(_ url: URL) -> Double {
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey : false]
        let urlAsset = AVURLAsset(url: url, options: options)
        let duration = round(Double(urlAsset.duration.value) / Double(urlAsset.duration.timescale))
        return duration
    }
    
    static func getDurationOfMediaFile(_ path: String) -> Double {
        let url = URL(fileURLWithPath: path)
        return getDurationOfMediaFile(url)
    }
}
