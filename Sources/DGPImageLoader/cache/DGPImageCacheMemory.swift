//
//  ImageCacheMemory.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 17/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DGPImageCacheMemory {
    
    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = DGPImageLoaderConfig.shared.defaultMemoryConfig.countLimit
        return cache
    }()
    
    private lazy var decodedImageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.totalCostLimit = DGPImageLoaderConfig.shared.defaultMemoryConfig.memoryLimit
        return cache
    }()
    
    private var lock = NSLock()
    
}

extension DGPImageCacheMemory: DGPImageCache {
    
    func image(for url: URL, targetSize: CGSize? = nil) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        
        if let object = decodedImageCache.object(forKey: url as AnyObject) as? UIImage {
            return object
        }
        
        if let object = imageCache.object(forKey: url as AnyObject) as? UIImage {
            let decodedObject = object.decodedImage(targetSize: targetSize)
            decodedImageCache.setObject(decodedObject, forKey: url as AnyObject, cost: decodedObject.diskSize)
            return decodedObject
        }
        return nil
    }
    
    func loadFromDisk(for url: URL, pathFile: String, targetSize: CGSize? = nil) -> UIImage? {
        guard let object = UIImage(contentsOfFile: pathFile) else {
            return nil
        }
        
        insertImage(object, for: url)
        return image(for: url, targetSize: targetSize)
    }
    
    func contains(_ url: URL) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        return !(imageCache.object(forKey: url as AnyObject) == nil)
    }
    
    func insertImage(_ image: UIImage?, for url: URL) {
        guard let image = image else {
            removeImage(for: url)
            return
        }
        
        imageCache.setObject(image, forKey: url as AnyObject, cost: 1)
    }
    
    func removeImage(for url: URL) {
        lock.unlock()
        defer { lock.unlock() }
        decodedImageCache.removeObject(forKey: url as AnyObject)
    }
    
    func removeAll() {
        lock.unlock()
        defer { lock.unlock() }
        decodedImageCache.removeAllObjects()
        imageCache.removeAllObjects()
    }    
    
}
