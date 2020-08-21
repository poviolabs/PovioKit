//
//  Data+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 21/08/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Foundation

public extension Data {
  /// Returns hexadecimal string representation of data object
  /// Usefull for e.g. printing out push notifications `deviceToken`
  var hexadecialString: String {
    map { String(format: "%02x", $0) }.joined()
  }
}
