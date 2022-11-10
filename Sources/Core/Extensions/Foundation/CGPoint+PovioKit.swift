//
//  CGPoint+PovioKit.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 10/11/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import ARKit

public extension CGPoint {
  /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
  init(_ vector: SCNVector3) {
    self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
  }

  /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
  var length: CGFloat {
    return sqrt(x * x + y * y)
  }
}

