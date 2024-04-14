//
//  MemoryCache.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import Foundation
import UIKit


class MemoryCache {
    static let shared = MemoryCache()
    
    private let cache = NSCache<NSURL, UIImage>()
    
    private init() {
    }
    
    func storeImage(_ image: UIImage?, forURL url: URL) {
        guard let image = image else { return }
        cache.setObject(image, forKey: url as NSURL)
    }
    
    func image(forURL url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func removeImage(forURL url: URL) {
        cache.removeObject(forKey: url as NSURL)
    }
    
    func removeAllImages() {
        cache.removeAllObjects()
    }
}
