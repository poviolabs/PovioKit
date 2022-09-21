//
//  Double+Povio.swift
//  PovioKit
//
//  Created by Borut Tomažin on 02/09/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public extension Double {
  /// Convert `degress` to `radians`
  var radians: Double {
    Measurement(value: self, unit: UnitAngle.degrees)
      .converted(to: .radians)
      .value
  }
  
  /// Convert `radians` to `degrees`
  var degrees: Double {
    Measurement(value: self, unit: UnitAngle.radians)
      .converted(to: .degrees)
      .value
  }
  
  /// Converst `miles` to `meters`
  var meters: Double {
    Measurement(value: self, unit: UnitLength.miles)
      .converted(to: .meters)
      .value
  }
  
  /// Converts `meters` to `miles`
  var miles: Double {
    Measurement(value: self, unit: UnitLength.meters)
      .converted(to: .miles)
      .value
  }
}
