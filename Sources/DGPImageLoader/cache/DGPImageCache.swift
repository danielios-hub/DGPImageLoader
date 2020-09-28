//
//  ImageCache.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 17/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

protocol DGPImageCache {
    
    func contains(_ url: URL) -> Bool 
    func image(for url: URL, targetSize: CGSize?) -> UIImage?
    func insertImage(_ image: UIImage?, for url: URL)
    func removeImage(for url: URL)
    func removeAll()
}
