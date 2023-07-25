//
//  UIDevice+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import UIKit

public extension UIDevice {
  /// Returns current device OS version e.g. `12.1.0`
  var osVersion: String {
    systemVersion
  }
  
  /// Returns device name, e.g. `iPhone`
  var deviceName: String {
    model
  }
  
  /// Returns device code name, e.g. `iPhone8.4`
  var deviceCodeName: String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    return machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
  }
}
