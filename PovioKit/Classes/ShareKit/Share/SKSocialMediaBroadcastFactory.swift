//
//  SKSocialMediaAuthenticator.swift
//  PovioKit
//
//  Created by Toni Kocjan on 37/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import Foundation

class SKSocialMediaBroadcastFactory {
  let assetLibraryProvider: SKAssetLibraryFacade
  
  init(albumName: String, libraryProvider: SKAssetLibraryTemplate, assetDownloader: SKAssetDownloaderProtocol) {
    self.assetLibraryProvider = SKAssetLibraryFacade(albumName: albumName,
                                                     libraryProvider: libraryProvider,
                                                     assetDownloader: assetDownloader)
  }
  
  func broadcast(on socialmedia: SKSocialMediaKind) -> SKSocialMediaBroadcast {
    switch socialmedia {
    case .facebook:
      return SKFacebookFacade(assetLibraryProvider: assetLibraryProvider)
    case .instagram:
      return SKInstagramBroadcast(assetLibraryProvider: assetLibraryProvider)
    case .twitter:
      return SKTwitterFacade(assetDownloader: assetLibraryProvider.assetDownloader)
    default:
      fatalError("not yet supported")
    }
  }
}
