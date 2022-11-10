//
//  UIGestureRecognizer+PovioKit.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 10/11/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import UIKit

public extension UIGestureRecognizer {
  /// Get center of touches in view
  func center(in view: UIView) -> CGPoint? {
    guard numberOfTouches > 0 else { return nil }
    
    let first = CGRect(origin: location(ofTouch: 0, in: view), size: .zero)

    let touchBounds = (1..<numberOfTouches).reduce(first) { touchBounds, index in
      return touchBounds.union(CGRect(origin: location(ofTouch: index, in: view), size: .zero))
    }

    return CGPoint(x: touchBounds.midX, y: touchBounds.midY)
  }
}
