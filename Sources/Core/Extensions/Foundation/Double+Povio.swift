//
//  Double+Povio.swift
//  PovioKit
//
//  Created by Borut Tomažin on 02/09/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public extension Double {
  /// Convert from one dimension to another one
  func convert(from: Dimension, to: Dimension) -> Double {
    Measurement(value: self, unit: from)
      .converted(to: to)
      .value
  }
}
