//
//  CacheManager.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import Foundation

private var cachesDirectory: NSString {
    let searchPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
    return searchPath[searchPath.count - 1] as NSString
}
let cacheDirectoryPath = cachesDirectory.appendingPathComponent("app_cache")
let cacheDirectoryURL = URL(fileURLWithPath: cacheDirectoryPath)

class CacheManager {
    static let shared = CacheManager()

    let mainCache: DiskCache

    init() {
        FileManager.createCacheDirectories()
        mainCache = DiskCache(directory: cacheDirectoryURL, capacity: 600 * 1024 * 1024) // 600MB general cache
    }
}


extension FileManager {
    static func createCacheDirectories() {
        do {
            try FileManager.default.createDirectory(atPath: cacheDirectoryPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            DebugManager.log("Error creating cache directory: \(error)")
        }
    }
}
