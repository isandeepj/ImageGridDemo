//
//  Queue.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import Foundation

struct Queue<T> {
    var array = [T]()

    var isEmpty: Bool {
        return array.isEmpty
    }

    var count: Int {
        return array.count
    }

    mutating func push(_ element: T) {
        array.append(element)
    }

    mutating func pop() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }

    mutating func dropFirst() {
        if !isEmpty {
            array.removeFirst()
        }
    }

    mutating func dropItems(remaining: Int) {
        while array.count > remaining {
            dropFirst()
        }
    }

    mutating func re() {
        array = []
    }

    var first: T? {
        return array.first
    }
}
