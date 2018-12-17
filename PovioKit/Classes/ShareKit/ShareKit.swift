//
//  PovioKit.swift
//  PovioKit
//
//  Created by Toni Kocjan on 17/12/2018.
//

import UIKit
import FBSDKCoreKit

public class ShareKit {
  // MARK: - Dependencies
  public var assetDownloader: SKAssetDownloaderProtocol? {
    didSet { initializeMediator() }
  }
  public var albumName: String = "Shared" {
    didSet { initializeMediator() }
  }
  
  // MARK: - Delegate
  public weak var delegate: SKSocialMediaMediatorDelegate? {
    didSet { mediator?.delegate = delegate }
  }
  
  // MARK: - Internal
  private var mediator: SKSocialMediaMediator?
  private let libraryProvider: SKAssetLibraryTemplate = SKAssetLibraryProvider()
  
  // MARK: - Shared
  public static let shared = ShareKit()
  
  public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    FBSDKApplicationDelegate
      .sharedInstance()
      .application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  public func sharePost(_ post: SKSocialMediaPost, on socialMedia: SKSocialMediaKind, from: UIViewController, success: (() -> Void)?, failure: @escaping ((Error) -> Void)) {
    mediator?.sharePost(post, on: socialMedia, from: from, success: success, failure: failure)
  }
}

private extension ShareKit {
  func initializeMediator() {
    guard let assetDownloader = assetDownloader else { return }
    let factory = SKSocialMediaBroadcastFactory(albumName: albumName, libraryProvider: libraryProvider, assetDownloader: assetDownloader)
    mediator = SKSocialMediaMediator(factory: factory, delegate: delegate)
  }
}
