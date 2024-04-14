//
//  LoadOperation.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import Foundation
class LoadOperation: ConcurrentOperation {
    var downloadableFile: ResourceDownloadable

    init(_ downloadableFile: ResourceDownloadable, completion: (() -> Void)? = nil) {
        self.downloadableFile = downloadableFile
        super.init()
        self.completionBlock = completion
    }

    override func main() {
        if downloadableFile.fileExists() {
            self.finish()
        } else {
            // This shouldn't happen!
            self.finish()
        }
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let rhsOperation = object as? LoadOperation else { return false }
        let lhsFile = self.downloadableFile
        let rhsFile = rhsOperation.downloadableFile
        return lhsFile == rhsFile
    }
}
