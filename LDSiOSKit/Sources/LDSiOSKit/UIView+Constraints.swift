//
//  UIView+Constraints.swift
//  CardsKit
//
//  Created by Luke Street on 2/7/19.
//

#if os(iOS)
import UIKit

extension UIView {
    public enum Side {
        case top, bottom, leading, trailing
    }
    
    @discardableResult
    public func pin(_ side: Side, to view: UIView, offsetBy offset: CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        switch side {
        case .top:
            return self.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: offset)
                .activate()
        case .bottom:
            return self.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -offset)
                .activate()
        case .leading:
            return self.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: offset)
                .activate()
        case .trailing:
            return self.trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -offset)
                .activate()
        }
    }
    
    @discardableResult
    public func pin(_ sides: [Side], to view: UIView, offsetBy offset: CGFloat = 0.0) -> [NSLayoutConstraint] {
        return sides.map { side in
            return pin(side, to: view, offsetBy: offset)
        }
    }
    
    public func recurrThroughSubviews(_ action: (UIView) -> Void) {
        action(self)
        subviews.forEach{ $0.recurrThroughSubviews(action) }
    }
    
    public enum Direction {
        case horizontally, vertically
    }
    
    @discardableResult
    public func center(_ direction: Direction, in view: UIView) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        switch direction {
        case .horizontally:
            return centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).activate()
        case .vertically:
            return centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).activate()
        }
    }
    
    @discardableResult
    public func center(_ direction: [Direction], in view: UIView) -> [NSLayoutConstraint] {
        return direction.map { direction in
            return center(direction, in: view)
        }
    }
    
    @discardableResult
    public func size(width: CGFloat? = nil, height: CGFloat? = nil) -> [NSLayoutConstraint] {
        return [
            {
                guard let width = width else { return nil }
                return widthAnchor.constraint(equalToConstant: width).activate()
            }(),
            
            {
                guard let height = height else { return nil }
                return heightAnchor.constraint(equalToConstant: height).activate()
            }()
            
            ].compactMap{ $0 }
    }
}

public extension Array where Element == UIView.Direction {
    public static var horizontallyAndVertically: [UIView.Direction] {
        return [.horizontally, .vertically]
    }
}

public extension Array where Element == UIView.Side {
    public static var horizontal: [UIView.Side] {
        return [.leading, .trailing]
    }
    
    public static var vertical: [UIView.Side] {
        return [.top, .bottom]
    }
    
    public static var all: [UIView.Side] {
        return horizontal + vertical
    }
}
#endif
