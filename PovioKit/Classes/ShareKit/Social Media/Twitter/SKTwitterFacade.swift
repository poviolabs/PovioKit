//
//  SKTwitterFacade.swift
//  PovioKit
//
//  Created by Toni Kocjan on 37/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import TwitterKit

class SKTwitterFacade {
  let authenticator = SKTwitterAuthenticator()
  let assetDownloader: SKAssetDownloaderProtocol
  private(set) lazy var broadcast = SKTwitterBroadcast(assetDownloader: assetDownloader)
  weak var delegate: SKSocialMediaMediatorDelegate? {
    didSet { broadcast.delegate = delegate }
  }
  
  init(assetDownloader: SKAssetDownloaderProtocol) {
    self.assetDownloader = assetDownloader
  }
}

extension SKTwitterFacade: SKSocialMediaBroadcast {
  ///   Share post on `Twitter`:
  ///    - if user didn't login with Twitter yet, login procedure will get executed first
  func sharePost(_ post: SKSocialMediaPost, from viewController: UIViewController, success: (() -> Void)?, failure: ((Error) -> Void)?) {
    let share = {
      self.broadcast.sharePost(post, from: viewController, success: success, failure: failure)
    }
    
    if authenticator.isLoggedIn {
      share()
    } else {
      authenticator.login(success: { session in
        share()
      }, failure: { error in
        print("Login to twitter failed with error: \(error.localizedDescription)")
        failure?(error)
      })
    }
  }
}
