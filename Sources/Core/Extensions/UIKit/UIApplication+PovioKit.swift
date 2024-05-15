//
//  UIApplication+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomažin on 13/11/2020.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UIApplication {
  /// Opens `Settings` app for current app.
  func openAppSettings() {
    URL(string: UIApplication.openSettingsURLString).map(openUrl)
  }
  
  /// Opens `App Store` and deep linking to the app with provided id.
  func openAppStore(appName: String, appleAppId: String) {
    guard let url = URL(string: "itms-apps://apps.apple.com/us/app/\(appName)/id\(appleAppId)") else { return }
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
  /// Returns bundle id
  var bundleId: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? "/"
  }
  
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
#endif
