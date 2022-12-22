//
//  CGPoint+PovioKit.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 10/11/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import ARKit

public extension float4x4 {
  /// Treats matrix as a (right-hand column-major convention) transform matrix
  /// and factors out the translation component of the transform.
  var translation: SIMD3<Float> {
    get {
      let translation = columns.3
      return [translation.x, translation.y, translation.z]
    }
    set(newValue) {
      columns.3 = [newValue.x, newValue.y, newValue.z, columns.3.w]
    }
  }
  
  /// Factors out the orientation component of the transform.
  var orientation: simd_quatf {
    return simd_quaternion(self)
  }
  
  /// Creates a transform matrix with a uniform scale factor in all directions.
  init(uniformScale scale: Float) {
    self = matrix_identity_float4x4
    columns.0.x = scale
    columns.1.y = scale
    columns.2.z = scale
  }
}
