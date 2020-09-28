//
//  DGPDataTask.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 16/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DGPDataTask {
    fileprivate var task: URLSessionDataTask
    public private(set) var url: URL
    fileprivate var mutableData: NSMutableData
    fileprivate var options: Set<DGPDownloadOption>
    fileprivate var started = false
    
    struct TaskCallBack {
        var block: DGPImageDownloader.CompletionDownloadHandler
    }
    
    var callbacks: [TaskCallBack]
    
    init(task: URLSessionDataTask, url: URL, options: Set<DGPDownloadOption>, completion: DGPImageDownloader.CompletionDownloadHandler?) {
        self.task = task
        self.url = url
        self.options = options
        callbacks = []
        mutableData = NSMutableData()
        
        if let completion = completion {
            addCallback(block: completion)
        }
    }
    
    func start() {
        guard !started else { return }
        started = true
        task.resume()
    }
    
    func cancel() {
        task.cancel()
    }

    func didReceiveData(_ data: Data) {
        mutableData.append(data)
    }
    
    func completed(with error: Error?) {

        if let error = error {
            let result = ImageLoadingResult(image: nil, url: url, originalData: mutableData as Data, error: error)
            finish(with: result)
            return
        }
        
        var image = UIImage(data: mutableData as Data)

        if image == nil {
            print("error decoded image")
            let result = ImageLoadingResult(image: nil, url: url, originalData: mutableData as Data, error: error ?? DGPError.notAnImage)
            finish(with: result)
            return
        }
        
        image = saveImage(image!, memory: options.contains(.cacheMemory), disk: options.contains(.cacheDisk))
        
        let result = ImageLoadingResult(image: image, url: url, originalData: mutableData as Data, error: nil)
        finish(with: result)
    }
    
    func saveImage(_ image: UIImage, memory: Bool, disk: Bool) -> UIImage {

        if disk {
            let diskCache = DGPImageDownloader.shared.diskCache
            diskCache.insertImage(image, for: url)
            
            if !memory {
                return diskCache.image(for: url, targetSize: needToResizeImage(options: options)) ?? image
            }
        }
        
        if memory {
            let memoryCache = DGPImageDownloader.shared.memoryCache
            memoryCache.insertImage(image, for: url)
            return memoryCache.image(for: url, targetSize: needToResizeImage(options: options)) ?? image
        }
        
        return image
    }
    
    //MARK: - CallBack
    
    func addCallback(block: @escaping DGPImageDownloader.CompletionDownloadHandler) {
        let callback = TaskCallBack(block: block)
        callbacks.append(callback)
    }
    
    private func finish(with result: ImageLoadingResult) {
        callbacks.forEach { closure in
            DispatchQueue.main.async {
                closure.block(result)
            }
        }
    }
    
    
    
    
    
}
