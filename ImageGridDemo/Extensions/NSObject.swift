//
//  NSObject.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import Foundation
import UIKit

extension NSObjectProtocol {

    static var className: String {
        return String(describing: self)
    }
}
