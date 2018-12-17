//
//  SKFacebookFacade.swift
//  PovioKit
//
//  Created by Toni Kocjan on 37/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import UIKit

class SKFacebookFacade {
  let authenticator = SKFacebookAuthenticator()
  let assetLibraryProvider: SKAssetLibraryFacade
  weak var delegate: SKSocialMediaMediatorDelegate? {
    didSet { broadcast.delegate = delegate }
  }
  private(set) lazy var broadcast = SKFacebookBroadcast(authenticator: authenticator,
                                                      assetLibraryProvider: assetLibraryProvider,
                                                      imagesDownloader: SKAsyncImagesDownloadWorker(assetDownloader: self.assetLibraryProvider.assetDownloader))
  
  init(assetLibraryProvider: SKAssetLibraryFacade) {
    self.assetLibraryProvider = assetLibraryProvider
  }
}

extension SKFacebookFacade: SKSocialMediaBroadcast {
  ///   Share post on `Facebook`:
  ///    - if user didn't login with FB yet, login procedure will get executed first
  func sharePost(_ post: SKSocialMediaPost, from viewController: UIViewController, success: (() -> Void)?, failure: ((Error) -> Void)?) {
    let share = {
      self.broadcast.sharePost(post, from: viewController, success: success, failure: failure)
    }
    
    if authenticator.isAccessTokenValid {
      share()
    } else {
      authenticator.login(readPermissions: SKFacebookAuthenticator.Permission.defaultPermissions, success: { _ in
        share()
      }, failure: { error in
        print("Login to facebook failed with error: \(error.localizedDescription)")
        failure?(error)
      })
    }
  }
}
