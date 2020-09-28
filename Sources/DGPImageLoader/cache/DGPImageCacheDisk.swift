//
//  DGPImageCacheDisk.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 18/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import UIKit

class DGPImageCacheDisk {
    
    enum DiskError: Error {
        case somethingWentWrong
        case createDirectory(String)
    }
    
    let fileManager: FileManager
    let directory = "DGPImageLoader"
    var folderURL: URL?
    let fileExtension = "jpeg"
    let compression : CGFloat = 0.8
    
    var isInit = false
    
    init() {
        fileManager = FileManager.default
    }
    
    func setup() throws {
        if !isInit {
            isInit = true
            
            let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            
            if let documentURL = documentURL {
                folderURL = documentURL.appendingPathComponent(directory)
                
                guard let folderURL = folderURL else {
                    throw DiskError.somethingWentWrong
                }
                
                var isDir : ObjCBool = false
                if fileManager.fileExists(atPath: folderURL.path, isDirectory:&isDir) {
                    if !isDir.boolValue {
                        let msg = "error: \(folderURL.absoluteString) not a directory"
                        print(msg)
                        throw DiskError.createDirectory(msg)
                    }
                } else {
                    // file does not exist
                    do {
                        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false)
                    } catch {
                        throw DiskError.createDirectory(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func cacheFilename(url: URL) -> URL? {
        let name = url.lastPathComponent
        return folderURL?.appendingPathComponent(name)
    }
    
}

//MARK: - Image Cache protocol

extension DGPImageCacheDisk: DGPImageCache {
    
    func contains(_ url: URL) -> Bool {
        guard let fileURL = cacheFilename(url: url) else {
            return false
        }
        
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    func image(for url: URL, targetSize: CGSize? = nil) -> UIImage? {
        guard let fileURL = cacheFilename(url: url) else {
            return nil
        }
        
        guard let object = UIImage(contentsOfFile: fileURL.path) else {
            return nil
        }
        
        return object.decodedImage(targetSize: targetSize)
    }
    
    func insertImage(_ image: UIImage?, for url: URL) {
        guard let fileURL = cacheFilename(url: url) else {
            return
        }
        
        guard let image = image else {
            removeImage(for: fileURL)
            return
        }
        
        save(image, url: fileURL)
    }
    
    func removeImage(for url: URL) {
        guard let fileURL = cacheFilename(url: url) else {
            return
        }
        try? removeIfExist(at: fileURL)
    }
    
    func removeAll() {
        guard let folderURL = folderURL else {
            return
        }
        
        do {
            try fileManager.contentsOfDirectory(atPath: folderURL.path).forEach { file in
                let filePath = self.folderURL!.appendingPathComponent(file)
                try fileManager.removeItem(atPath: filePath.path)
            }
        } catch {
            print("error removing files \(error.localizedDescription)")
        }
    }
    
    
}

//MARK: - Handler read/write disk

extension DGPImageCacheDisk {
    
    func save(_ image: UIImage, url: URL) {
        guard let data = image.jpegData(compressionQuality: compression) else {
            return
        }
        
        do {
            try removeIfExist(at: url)
            try data.write(to: url)
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func removeIfExist(at url: URL) throws {
        let exists = fileManager.fileExists(atPath: url.absoluteString)
        
        if exists {
            try fileManager.removeItem(at: url)
        }
    }
    
}
