//
//  DGPImageDownloader.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 14/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

enum DGPError : Error {
    case general(String)
    case notAnImage
}

public struct ImageLoadingResult {

    /// The downloaded image.
    public let image: UIImage?

    /// Original URL of the image request.
    public let url: URL?

    /// The raw data received from downloader.
    public let originalData: Data?
    
    ///error of the request
    public let error: Error?
}

class DGPImageDownloader: NSObject {
    
    typealias CompletionDownloadHandler = (ImageLoadingResult) -> Void
    
    private var session : URLSession!
    private var config: URLSessionConfiguration
    private let timeout = 15.0
    private let manager : DGPTaskManager
    private var queue = DispatchQueue(label: "requestQueue", qos: .userInitiated)
    
    static let shared = DGPImageDownloader()
    
    
    lazy var memoryCache = {
        return DGPImageCacheMemory()
    }()
    
    lazy var diskCache = {
        return DGPImageCacheDisk()
    }()
    
    override private init() {
        config = URLSessionConfiguration.default
        manager = DGPTaskManager()
        super.init()
        
        setup()
    }
    
    func setup() {
        session = URLSession(configuration: config, delegate: manager, delegateQueue: nil)
    }
    
    func download(_ url: URL, options: Set<DGPDownloadOption>? = nil, completionHandler: CompletionDownloadHandler? = nil) {
        queue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            if let image = self?.checkImageInCache(url, options: options) {
                let result = ImageLoadingResult(image: image, url: url, originalData: nil, error: nil)
                self?.callback(with: result, completionHandler: completionHandler)
                return
            }
            
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: strongSelf.timeout)
            let task = strongSelf.session.dataTask(with: request)
            let optionsDownload = options ?? DGPImageLoaderConfig.shared.defaultOptions
            strongSelf.manager.addTask(task, url: url, options: optionsDownload, completion: completionHandler)
        }
    }
    
    func checkImageInCache(_ url: URL, options: Set<DGPDownloadOption>? = nil) -> UIImage? {
        if let options = options, options.contains(.cacheMemory) {
            
            if let image = self.memoryCache.image(for: url, targetSize: needToResizeImage(options: options)) {
                print("image from memory cache")
                return image
            }
        }
        
        if let options = options, options.contains(.cacheDisk) {
            do {
                try diskCache.setup()
                if diskCache.contains(url) {
                    if options.contains(.cacheMemory), let pathFile = diskCache.cacheFilename(url: url) {
                        print("image from disk-memory")
                        return memoryCache.loadFromDisk(for: url, pathFile: pathFile.path, targetSize: needToResizeImage(options: options))
                    } else if let image = diskCache.image(for: url, targetSize: needToResizeImage(options: options)) {
                        print("image from disk")
                        return image
                    }
                }
                
            } catch {
                print("failed to initialize disk cache")
            }
        }
        
        return nil
    }
    
    func callback(with result: ImageLoadingResult, completionHandler: CompletionDownloadHandler?) {
        if let completionHandler = completionHandler {
            DispatchQueue.main.async {
                completionHandler(result)
            }
        }
    }
}

