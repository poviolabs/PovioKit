//
//  PovioKit.swift
//  PovioKit
//
//  Created by Toni Kocjan on 17/12/2018.
//

import UIKit
import FBSDKCoreKit

class ShareKit {
  // Dependencies
  var assetDownloader: SKAssetDownloaderProtocol!
  var albumName: String = "Social Share"
  
  static let shared = ShareKit()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    FBSDKApplicationDelegate
      .sharedInstance()
      .application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
