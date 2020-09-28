//
//  DGPImageLoaderUtils.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 17/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import CoreGraphics

internal func needToResizeImage(options: Set<DGPDownloadOption>) -> CGSize? {
    var sizeTo: CGSize? = nil
    
    options.forEach {
        switch $0 {
        case .resized(let size):
            if size != .zero {
                sizeTo = size
            }
        default:
            break
        }
    }
    
    return sizeTo
}
