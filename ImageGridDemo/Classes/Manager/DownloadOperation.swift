//
//  DownloadOperation.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import Foundation

class DownloadOperation: ConcurrentOperation {
    var downloadableFile: ResourceDownloadable
    private var downloadTask: URLSessionDownloadTask?
    
    init(_ downloadableFile: ResourceDownloadable, completion: (() -> Void)? = nil) {
        self.downloadableFile = downloadableFile
        super.init()
        self.completionBlock = completion
    }
    
    override func main() {
        if downloadableFile.fileExists() {
            self.finish()
        } else {
            guard let remoteURL = downloadableFile.fileRemoteURL(), let diskURL = downloadableFile.filePath() else {
                self.finish()
                return
            }
            downloadTask = URLSession.shared.downloadTask(with: remoteURL) { [weak self] (location, response, error) in
                guard let weakSelf = self else { return }
                // Check if the operation is canceled
                guard !weakSelf.isCancelled else {
                    weakSelf.finish()
                    return
                }
                
                if let error = error {
                    DebugManager.log("Download failed with error: \(error)")
                } else if let location = location {
                    do {
                        if FileManager.default.fileExists(atPath: diskURL.path) {
                            try FileManager.default.removeItem(at: diskURL)
                        }
                        
                        let directory = diskURL.deletingLastPathComponent()
                        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                        
                        try FileManager.default.moveItem(at: location, to: diskURL)
                        CacheManager.shared.mainCache.addURL(diskURL)
                    } catch {
                        DebugManager.log("Error moving downloaded file: \(error)")
                    }
                }
                // Ensure that the operation is marked as finished even if canceled during the download
                weakSelf.finish()
            }
            
            downloadTask?.resume()
        }
    }
    override func cancel() {
        downloadTask?.cancel()
        super.cancel()
    }
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhsOperation = object as? DownloadOperation else { return false }
        let lhsFile = self.downloadableFile
        let rhsFile = rhsOperation.downloadableFile
        
        return lhsFile == rhsFile
    }
}
