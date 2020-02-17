//
//  UIView+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import UIKit

public extension UIEdgeInsets {
  /// Apply the same value to all edges
  init(all: CGFloat) {
    self.init(top: all, left: all, bottom: all, right: all)
  }
  
  /// Apply the same value to top and bottom edges
  init(vertical: CGFloat) {
    self.init(top: vertical, left: 0, bottom: vertical, right: 0)
  }
  
  /// Apply the same value to left and right edges
  init(horizontal: CGFloat) {
    self.init(top: 0, left: horizontal, bottom: 0, right: horizontal)
  }
  
  /// Apply the same value for to top/bottom and left/right edges
  init(vertical: CGFloat, horizontal: CGFloat) {
    self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
  }
}

public extension UIEdgeInsets {
  /// Returns vertical edges dimensions combined
  var vertical: CGFloat {
    return top + bottom
  }
  
  /// Returns horizontal edges dimensions combined
  var horizontal: CGFloat {
    return left + right
  }
}
