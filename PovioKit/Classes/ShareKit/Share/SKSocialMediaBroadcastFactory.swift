//
//  SKSocialMediaAuthenticator.swift
//  PovioKit
//
//  Created by Toni Kocjan on 37/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import Foundation

class SKSocialMediaBroadcastFactory {
  private(set) lazy var assetLibraryProvider = SKAssetLibraryFacade(albumName: ShareKit.shared.albumName,
                                                                    libraryProvider: SKAssetLibraryProvider(),
                                                                    assetDownloader: ShareKit.shared.assetDownloader)
  
  func broadcast(on socialmedia: SKSocialMediaKind) -> SKSocialMediaBroadcast {
    switch socialmedia {
    case .facebook:
      return SKFacebookFacade(assetLibraryProvider: assetLibraryProvider)
    default:
      fatalError()
    }
  }
}
