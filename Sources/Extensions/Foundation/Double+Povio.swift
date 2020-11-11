//
//  Double+Povio.swift
//  PovioKit
//
//  Created by Borut Tomažin on 11/11/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Foundation

public extension Double {
  typealias Meters = Double
  typealias Miles = Double
  
  /// Returns miles in meters
  var meters: Meters {
    self * 1609.344
  }
  
  /// Return meters in miles
  var miles: Miles {
    self / 1609.344
  }
}
