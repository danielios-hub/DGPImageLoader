//
//  DGPImageViewExtension.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 14/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

extension UIImageView {
    
    /// Download an UIImage and set to image property
    /// - Parameters:
    ///   - url: Source from the image
    ///   - placeholder: Image to be set before downloading the image
    ///   - options: allow to set cache from disk, memory and resize image
    ///   - completionHandler: block that will be call with the result of the download
    ///- Warning: if you provide a completion block, you need to set the image yourself
    public func dgp_setImage(with url: URL,
                      placeholder: UIImage? = nil,
                      options: Set<DGPDownloadOption>? = nil,
                      completionHandler: DGPCompletionHandler? = nil) {
        self.image = placeholder
        
        DGPImageDownloader.shared.download(url, options: options)  { [unowned self] result in
            
            if let completionHandler = completionHandler {
                completionHandler(result)
                return
            }
            
            guard let img = result.image else {
                print("something went wrong")
                return 
            }
            
            self.image = img
        }
    }
}
