//
//  UIStackView+Extensions.swift
//  CardsKit
//
//  Created by Luke Street on 2/9/19.
//

#if os(iOS)
import UIKit

extension UIStackView {
    public func addArrangedSubviews(_ views: [UIView]) {
        views.forEach(self.addArrangedSubview)
    }
}
#endif
