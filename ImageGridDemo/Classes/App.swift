//
//  App.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import Foundation
import UIKit
class App: NSObject {
    static let shared = App()
    var window: UIWindow?
    
    class var safeAreaInsets: UIEdgeInsets {
        if let window = App.shared.window {
            return window.safeAreaInsets
        } else if let window = UIApplication.shared.keyWindowActive {
            return window.safeAreaInsets
        }
        return UIEdgeInsets.zero
    }
}



extension UIApplication {
    var keyWindowActive: UIWindow? {
        // Get connected scenes
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
                .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
                .first(where: { $0 is UIWindowScene })
            // Get its associated windows
                .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
                .first(where: \.isKeyWindow)
        } else {
            // Fallback on earlier versions
            return UIApplication.shared.windows.first
        }
    }
}
