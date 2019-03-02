//
//  NSConstraint+Extensions.swift
//  CardsKit
//
//  Created by Luke Street on 2/7/19.
//

#if os(iOS)
import UIKit

extension NSLayoutConstraint {
    public func activate() -> NSLayoutConstraint {
        self.isActive = true
        return self
    }
    
    public func deactivate() -> NSLayoutConstraint {
        self.isActive = false
        return self
    }
}
#endif
