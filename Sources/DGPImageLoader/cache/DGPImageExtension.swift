//
//  DGPImageExtension.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 17/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

extension UIImage {

    // Rough estimation of how much memory image uses in bytes
    var diskSize: Int {
        guard let cgImage = cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
    
//    func decodedImage() -> UIImage {
////        guard let cgImage = cgImage else { return self }
////        let size = CGSize(width: cgImage.width, height: cgImage.height)
////        let colorSpace = CGColorSpaceCreateDeviceRGB()
////        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: cgImage.bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
////        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
////        guard let decodedImage = context?.makeImage() else { return self }
////        return UIImage(cgImage: decodedImage)
//
//
//
//        let size = CGSize(width: self.size.width * self.scale, height: self.size.height * self.scale)
//        let renderer = UIGraphicsImageRenderer(size: size)
//        let resized = renderer.image { content in
//            self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//        }
//        return resized
//    }
    
    func decodedImage(targetSize: CGSize? = nil) -> UIImage {
        let targetSize = targetSize ?? self.size
        let sizeTo = CGSize(width: targetSize.width * self.scale, height: targetSize.height * self.scale)
        let renderer = UIGraphicsImageRenderer(size: sizeTo)
        let resized = renderer.image { content in
            self.draw(in: CGRect(x: 0, y: 0, width: sizeTo.width, height: sizeTo.height))
        }
        return resized
    }
    
//    static func resizeImage(with data: Data, size: CGSize, scale: CGFloat) -> UIImage? {
//        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
//        let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions)!
//
//        let maxDimensionInPixels = max(size.width, size.height) * scale
//        let downsampleOptions = [
//            kCGImageSourceCreateThumbnailFromImageAlways: true,
//            kCGImageSourceShouldCacheImmediately: true,
//            kCGImageSourceCreateThumbnailWithTransform: true,
//            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
//        ] as CFDictionary
//
//        let downSampleImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
//        return UIImage(cgImage: downSampleImage)
//    }
}
