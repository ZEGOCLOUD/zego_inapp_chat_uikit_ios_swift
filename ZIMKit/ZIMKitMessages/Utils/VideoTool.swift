//
//  VideoTool.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/23.
//

import Foundation
import AVFoundation

class VideoTool {
    static func getFirstFrameImageAndDuration(with videoUrl: URL) -> (UIImage?, Double) {
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey : false]
        let urlAsset = AVURLAsset(url: videoUrl, options: options)
        let duration = round(Double(urlAsset.duration.value) / Double(urlAsset.duration.timescale))
        let gen = AVAssetImageGenerator(asset: urlAsset)
        gen.appliesPreferredTrackTransform = true
        gen.maximumSize = UIScreen.main.bounds.size
        let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 30)

        if let imageRef = try? gen.copyCGImage(at: time, actualTime: nil) {
            return (UIImage(cgImage: imageRef), duration)
        }
        return (nil, 0)
    }
}
