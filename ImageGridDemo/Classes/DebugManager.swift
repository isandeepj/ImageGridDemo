//
//  DebugManager.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import Foundation

class DebugManager {
    private static let queue = DispatchQueue(label: "ThreadSafeDebugManager.queue", attributes: .concurrent)
    private static var _allowPrint = true
    
    static var allowPrint: Bool {
        get {
            var result: Bool = false
            queue.sync {
                result = _allowPrint
            }
            return result
        } set {
            queue.async(flags: .barrier) {
                _allowPrint = newValue
            }
        }
    }
    class func log(_ items: Any...) {
        guard allowPrint else { return }
        
        for item in items {
            print("~\(item)")
        }
    }
}
