//
//  ImageCache.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/24.
//

import Foundation
import Kingfisher

public class ImageCache {

    public static func cachedImage(
        for key: String,
        isResize: Bool = false,
        isSync: Bool = false,
        completionHandler: @escaping (UIImage?) -> Void
    ) {
        var options: KingfisherOptionsInfo = []
        if isResize {
            let processor = ResizingImageProcessor(
                referenceSize: UIScreen.main.bounds.size,
                mode: .aspectFit)
            options.append(.processor(processor))
        }
        if isSync {
            options.append(.loadDiskFileSynchronously)
        }
        Kingfisher.ImageCache.default.retrieveImage(
            forKey: key,
            options: options,
            callbackQueue: isSync ? .untouch : .mainCurrentOrAsync
        ) { result in
            if case .success(let ret) = result {
                completionHandler(ret.image)
            } else {
                completionHandler(nil)
            }
        }
    }

    public static func storeImage(
        image: UIImage?,
        data: Data? = nil,
        for key: String,
        isResize: Bool = false
    ) {
        guard let image = image else { return }
        var cacheSerializer = DefaultCacheSerializer()
        cacheSerializer.preferCacheOriginalData = true
        var identifier = ""
        if isResize {
            let processor = ResizingImageProcessor(
                referenceSize: UIScreen.main.bounds.size,
                mode: .aspectFit)
            identifier = processor.identifier
        }
        Kingfisher.ImageCache.default.store(
            image,
            original: data,
            forKey: key,
            processorIdentifier: identifier,
            cacheSerializer: cacheSerializer)
    }

    public static func removeCache(
        for key: String?,
        isResize: Bool = false
    ) {
        guard let key = key else { return }
        var identifier = ""
        if isResize {
            let processor = ResizingImageProcessor(
                referenceSize: UIScreen.main.bounds.size,
                mode: .aspectFit)
            identifier = processor.identifier
        }
        Kingfisher.ImageCache.default.removeImage(
            forKey: key,
            processorIdentifier: identifier)
    }

    public static func containsCachedImage(
        for key: String?,
        isResize: Bool = false
    ) -> Bool {
        guard let key = key else { return false }
        var identifier = ""
        if isResize {
            let processor = ResizingImageProcessor(
                referenceSize: UIScreen.main.bounds.size,
                mode: .aspectFit)
            identifier = processor.identifier
        }
        return Kingfisher.ImageCache.default.isCached(
            forKey: key,
            processorIdentifier: identifier)
    }
}

public class ImageDownloader {
    public static func downloadImage(
        with path: String,
        completionHandler: ((Data?, UIImage?) -> Void)? = nil
    ) {

        guard let url = URL(string: path) else {
            completionHandler?(nil, nil)
            return
        }
        KingfisherManager.shared.retrieveImage(with: url) { value in
            print(value)
            switch value {
            case .success(let result):
                let data = result.image.gifData()
                completionHandler?(data, result.image)
            case .failure:
                completionHandler?(nil, nil)
            }
        }
    }
}
