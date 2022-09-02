//
//  Double+Povio.swift
//  PovioKit
//
//  Created by Borut Tomažin on 02/09/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public extension Double {
  var radians: Double {
    Measurement(value: self, unit: UnitAngle.degrees)
      .converted(to: .radians)
      .value
  }
  
  var degrees: Double {
    Measurement(value: self, unit: UnitAngle.radians)
      .converted(to: .degrees)
      .value
  }
}
