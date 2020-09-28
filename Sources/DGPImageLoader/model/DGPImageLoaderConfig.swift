//
//  DGPImageLoaderConfig.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 16/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import CoreGraphics

struct DGPImageLoaderConfig {
    static let shared = DGPImageLoaderConfig()
    
    let defaultOptions : Set<DGPDownloadOption>
    let defaultMemoryConfig = DGPMemoryConfig(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 100 MB
    var maxRequestSimultaneous = 3
    
    
    init() {
        defaultOptions = [.cacheDisk, .cacheMemory]
    }
}

struct DGPMemoryConfig {
    var countLimit: Int
    var memoryLimit: Int
}

enum DGPDownloadOption : Hashable {
    case cacheMemory
    case cacheDisk
    case resized(CGSize)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .resized(let size):
            hasher.combine(size.width / size.height)
        default:
            break
        }
    }
}
