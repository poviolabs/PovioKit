//
//  UIApplication+Povio.swift
//  PovioKit
//
//  Created by Borut Tomažin on 13/11/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit

public extension UIApplication {
  /// Opens `Settings` app for current app.
  func openAppSettings() {
    URL(string: UIApplication.openSettingsURLString).map(openUrl)
  }
  
  /// Passing the `number` will trigger the system call with "tel://" prefix.
  func call(_ number: String) {
    URL(string: "tel://" + number).map { openUrl($0) }
  }
  
  /// Opens given `url` if `canOpenURL` method returns true.
  func openUrl(_ url: URL) {
    guard canOpenURL(url) else { return }
    open(url, options: [:])
  }
}
