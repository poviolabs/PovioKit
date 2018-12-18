//
//  PovioKit.swift
//  PovioKit
//
//  Created by Toni Kocjan on 17/12/2018.
//

import FBSDKCoreKit
import TwitterKit

public class ShareKit {
  // MARK: - Dependencies
  private var assetDownloader: SKAssetDownloaderProtocol = SKAssetDownloader() {
    didSet { mediator = initializeMediator() }
  }
  private var albumName: String = "Shared" {
    didSet { mediator = initializeMediator() }
  }
  
  // MARK: - Delegate
  public weak var delegate: SKSocialMediaMediatorDelegate? {
    didSet { mediator.delegate = delegate }
  }
  
  // MARK: - Internal
  private lazy var mediator: SKSocialMediaMediator = self.initializeMediator()
  private let libraryProvider: SKAssetLibraryTemplate = SKAssetLibraryProvider()
  
  // MARK: - Shared
  public static let shared = ShareKit()
}

// MARK: - Configuration
public extension ShareKit {
  // MARK: - Global configuration
  public class Configuration {
    public var assetDownloader: SKAssetDownloaderProtocol = SKAssetDownloader()
    public var albumName = "Shared"
  }
  
  public func configure(configurationBlock: (Configuration) -> Void) {
    let configuration = Configuration()
    configurationBlock(configuration)
    self.assetDownloader = configuration.assetDownloader
    self.albumName = configuration.albumName
  }
  
  // MARK: - `TwitterKit` configuration
  public enum Twitter {
    public static func configure(withConsumerKey: String, consumerSecret: String) {
      TWTRTwitter.sharedInstance().start(withConsumerKey: withConsumerKey, consumerSecret: consumerSecret)
    }
  }
}

public extension ShareKit {
  public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    FBSDKApplicationDelegate
      .sharedInstance()
      .application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  public func sharePost(_ post: SKSocialMediaPost, on socialMedia: SKSocialMediaKind, from: UIViewController, success: (() -> Void)?, failure: @escaping ((Error) -> Void)) {
    mediator.sharePost(post, on: socialMedia, from: from, success: success, failure: failure)
  }
}

private extension ShareKit {
  func initializeMediator() -> SKSocialMediaMediator {
    let factory = SKSocialMediaBroadcastFactory(albumName: albumName,
                                                libraryProvider: libraryProvider,
                                                assetDownloader: assetDownloader)
    let mediator = SKSocialMediaMediator(factory: factory,
                                         delegate: delegate)
    return mediator
    
  }
}
