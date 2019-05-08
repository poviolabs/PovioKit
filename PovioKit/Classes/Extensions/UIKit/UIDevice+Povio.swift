//
//  UIDevice+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import UIKit

public extension UIDevice {
  /// Returns app name
  var appName: String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "/"
  }
  
  /// Returns App Store build, e.g. `84`
  var appBuild: String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "/"
  }
  
  /// Returns App Store app version, e.g. `1.9.3`
  var appVersion: String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "/"
  }
  
  /// Returns current device OS version e.g. `12.1.0`
  var osVersion: String {
    return systemVersion
  }
  
  /// Returns device name, e.g. `iPhone`
  var deviceName: String {
    return model
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
