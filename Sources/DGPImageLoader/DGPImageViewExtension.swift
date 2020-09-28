//
//  DGPImageViewExtension.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 14/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

extension UIImageView {
    
    typealias CompletionDownload = (ImageLoadingResult) -> Void
    
    func dgp_setImage(with url: URL,
                      placeholder: UIImage? = nil,
                      options: Set<DGPDownloadOption>? = nil,
                      completionHandler: CompletionDownload? = nil) {
        self.image = placeholder
        
        DGPImageDownloader.shared.download(url, options: options)  { result in
            
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
