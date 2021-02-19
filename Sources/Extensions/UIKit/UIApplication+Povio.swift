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
  
  /// Opens `App Store` and deep linking to the app with provided id.
  func openAppStore(appleAppId: String) {
    guard let url = URL(string: "itms-apps://apps.apple.com/us/app/via-regalo/id\(appleAppId)") else { return }
    open(url, options: [:], completionHandler: nil)
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

public extension UIApplication {
  /// Returns app name
  var name: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "/"
  }
  
  /// Returns App Store build, e.g. `84`
  var build: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "/"
  }
  
  /// Returns App Store app version, e.g. `1.9.3`
  var version: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "/"
  }
}
