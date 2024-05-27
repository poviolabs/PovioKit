//
//  AppInfo.swift
//  PovioKit
//
//  Created by Borut Tomazin on 22/05/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum AppInfo {
  /// Opens `Settings` app for current app.
#if os(iOS)
  public static func openSettings() {
    URL(string: UIApplication.openSettingsURLString).map(openUrl)
  }
#endif
  
  /// Opens `App Store` and deep linking to the app with provided id.
  public static func openAppStore(appName: String, appleAppId: String) {
    guard let url = URL(string: "itms-apps://apps.apple.com/us/app/\(appName)/id\(appleAppId)") else { return }
    openUrl(url)
  }
  
  /// Passing the `number` will trigger the system call with "tel://" prefix.
  public static func call(_ number: String) {
    URL(string: "tel://" + number).map { openUrl($0) }
  }
  
  /// Opens given `url` if `canOpenURL` method returns true.
  public static func openUrl(_ url: URL) {
#if os(iOS)
    guard UIApplication.shared.canOpenURL(url) else { return }
    UIApplication.shared.open(url, options: [:])
#elseif os(macOS)
    guard NSWorkspace.shared.urlForApplication(toOpen: url) != nil else { return }
    NSWorkspace.shared.open(url)
#endif
  }
  
  /// Returns bundle id
  public static var bundleId: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? "/"
  }
  
  /// Returns app name
  public static var name: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "/"
  }
  
  /// Returns App Store build, e.g. `84`
  public static var build: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "/"
  }
  
  /// Returns App Store app version, e.g. `1.9.3`
  public static var version: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "/"
  }
}
