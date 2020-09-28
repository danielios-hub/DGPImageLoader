//
//  DGPImageLoaderConfig.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 16/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import CoreGraphics

public struct DGPImageLoaderConfig {
    static let shared = DGPImageLoaderConfig()
    
    let defaultOptions : Set<DGPDownloadOption>
    let defaultMemoryConfig : DGPMemoryConfig
    var maxRequestSimultaneous = 3
    
    
    init() {
        defaultOptions = [.cacheDisk, .cacheMemory]
        defaultMemoryConfig = DGPMemoryConfig(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 100 MB
    }
    
    init(memoryCache: Bool = true,
         diskCache: Bool = true,
         objectsCacheCount: Int = 100,
         memoryCacheMBLimit: Int = 1024 * 1024 * 100,
         resizeTo: CGSize? = nil) {
        
        var options : Set<DGPDownloadOption> = []
        if memoryCache {
            options.insert(.cacheMemory)
        }
        
        if diskCache {
            options.insert(.cacheDisk)
        }
        
        if let size = resizeTo {
            options.insert(.resized(size))
        }
        
        defaultOptions = options
        defaultMemoryConfig = DGPMemoryConfig(countLimit: objectsCacheCount, memoryLimit: memoryCacheMBLimit)
    }
}

internal struct DGPMemoryConfig {
    var countLimit: Int
    var memoryLimit: Int
}

public enum DGPDownloadOption : Hashable {
    case cacheMemory
    case cacheDisk
    case resized(CGSize)
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .resized(let size):
            hasher.combine(size.width / size.height)
        default:
            break
        }
    }
}
