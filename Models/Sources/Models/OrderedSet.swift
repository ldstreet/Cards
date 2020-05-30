//
//  OrderedSet.swift
//  BusinessCard
//
//  Created by Luke Street on 1/30/20.
//  Copyright © 2020 Luke Street. All rights reserved.
//

import Foundation

public struct OrderedSet<T: Hashable>: IteratorProtocol, Sequence, ExpressibleByArrayLiteral {
    
    //MARK: - IteratorProtocol
    public typealias Element = T
    
    private var _count = 0
    public mutating func next() -> Element? {
        guard _count < internalArray.count else { return nil }
        
        defer { _count += 1 }
        
        return internalArray[_count]
    }
    
    
    //MARK: - Properties
    private var internalArray = [Element]()
    private var hashToIndexMap = [Int: Int]()
    public var count: Int {
        return internalArray.count
    }
    
    //MARK: - Initializers
    public init() { }
    
    // O(n)
    public init(arrayLiteral elements: Element...) {
        internalArray = Array(elements)
        for elem in elements.enumerated() {
            hashToIndexMap[elem.element.hashValue] = elem.offset
        }
    }
    
    //MARK: - Funcs
    
    // O(1)
    public mutating func append(_ element: Element) {
        internalArray.append(element)
        hashToIndexMap[element.hashValue] = internalArray.count - 1
    }
    
    // O(1)
    public mutating func remove(_ element: Element) {
        guard let index = hashToIndexMap[element.hashValue] else {
            print("OrderedSet does not contain element \(element))")
            return
        }
        internalArray.remove(at: index)
        hashToIndexMap.removeValue(forKey: element.hashValue)
    }
    
    // O(1)
    public func contains(_ element: Element) -> Bool {
        return hashToIndexMap[element.hashValue] != nil
    }
    
}

extension OrderedSet: Codable where T: Codable {}
extension OrderedSet: Hashable where T: Hashable {}
