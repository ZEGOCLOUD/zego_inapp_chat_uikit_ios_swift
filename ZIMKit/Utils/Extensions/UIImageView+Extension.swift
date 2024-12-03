//
//  UIImageView+Extension.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/24.
//

import Foundation
import Kingfisher

public typealias DownloadMediaProgressBlock = ((_ receivedSize: Int64, _ totalSize: Int64) -> Void)

extension UIImageView {
    public func loadImage(
        with imageName: String?,
        placeholder: String?,
        maxSize: CGSize = UIScreen.main.bounds.size,
        isResize: Bool = false,
        progressBlock: DownloadMediaProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
    ) {
        var defaultImage: UIImage?
        if let placeholder = placeholder {
            defaultImage = loadImageSafely(with: placeholder)
        }
        self.loadImage(
            with: imageName,
            placeholder: defaultImage,
            maxSize: maxSize,
            isResize: isResize,
            progressBlock: progressBlock,
            completionHandler: completionHandler)
    }

    public func loadImage(
        with imageName: String?,
        placeholder: UIImage? = nil,
        maxSize: CGSize = UIScreen.main.bounds.size,
        isResize: Bool = false,
        progressBlock: DownloadMediaProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
    ) {
        let url: URL? = imageName != nil ? URL(string: imageName!) : nil
        var options: KingfisherOptionsInfo = [
            .transition(.fade(0.25)),
            .backgroundDecode
        ]
        if maxSize != .zero && isResize == true {
            //            let processor = DownsamplingImageProcessor(size: maxSize)
            let processor = ResizingImageProcessor(referenceSize: maxSize, mode: .aspectFill)
            options.append(.processor(processor))
        }
        
        if let path = imageName, FileManager.default.fileExists(atPath: path) {
            let provider = LocalFileImageDataProvider(fileURL: URL(fileURLWithPath: path))
            self.kf.setImage(
                with: provider,
                placeholder: placeholder,
                options: options,
                progressBlock: progressBlock,
                completionHandler: completionHandler)
        } else {
            self.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: options,
                progressBlock: progressBlock,
                completionHandler: completionHandler)
        }
    }
}
