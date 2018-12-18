//
//  InstagramBroadcast.swift
//  Facelift
//
//  Created by Toni Kocjan on 18/07/2018.
//  Copyright © 2018 poviolabs. All rights reserved.
//

import UIKit

///
/// This implementation of the `SocialMediaBroadcast` for instagram works by hooking to Instagram via `instagram://library?AssetPath=[asset_url]` hook
/// by providing an url to the asset we want Instagram app to open. Before we can do this we save the `image` to the `Facelift` album (which is also created if necessary).
/// TODO: - We might consider clearing the album every now and then, so we don't use too much space because of the images.
///
class SKInstagramBroadcast: SKSocialMediaBroadcast {
  enum SKInstagramBroadcastError: Error {
    case deepLinkFailedToOpen
    case noMedia
  }
  
  let instagramURL: URL = "instagram://"
  let libraryProvider: SKAssetLibraryFacade
  weak var delegate: SKSocialMediaMediatorDelegate?
  
  init(assetLibraryProvider: SKAssetLibraryFacade) {
    self.libraryProvider = assetLibraryProvider
  }
  
  func sharePost(_ post: SKSocialMediaPost, from viewController: UIViewController, success: (() -> Void)?, failure: ((Error) -> Void)?) {
    guard UIApplication.shared.canOpenURL(instagramURL) else {
      failure?(SKSocialMediaError.applicationNotInstalled("instagram"))
      return
    }
    
    if let imageUrl = post.imageUrls.first {
      shareImage(imageUrl, success: success, failure: failure)
    } else if let videoUrl = post.videoUrls.first {
      shareVideo(videoUrl, success: success, failure: failure)
    } else {
      failure?(SKInstagramBroadcastError.noMedia)
    }
  }
}

private extension SKInstagramBroadcast {
  func shareImage(_ imageUrl: URL, success: (() -> Void)?, failure: ((Error) -> Void)?) {
    delegate?.didBeginLoading(socialMediaBroadcast: self)
    libraryProvider.saveImage(remoteUrl: imageUrl, success: { url in
      self.delegate?.didFinishLoading(socialMediaBroadcast: self)
      self.postToInstagram(assetLibraryUrl: url, success: success, failure: failure)
    }, failure: { error in
      self.delegate?.didFinishLoading(socialMediaBroadcast: self)
      failure?(error)
    })
  }
  
  func shareVideo(_ videoUrl: URL, success: (() -> Void)?, failure: ((Error) -> Void)?) {
    delegate?.didBeginLoading(socialMediaBroadcast: self)
    
    libraryProvider.saveVideo(fromUrl: videoUrl, success: { asset, url in
      self.delegate?.didFinishLoading(socialMediaBroadcast: self)
      guard let assetLibraryUrl = self.assetLibraryUrl(from: url, assetIdentifier: asset.localIdentifier) else {
        failure?(SKInstagramBroadcastError.noMedia)
        return
      }
      
      self.postToInstagram(assetLibraryUrl: assetLibraryUrl, success: success, failure: failure)
    }, failure: { error in
      self.delegate?.didFinishLoading(socialMediaBroadcast: self)
      failure?(error)
    })
  }
  
  func postToInstagram(assetLibraryUrl url: URL, success: (() -> Void)?, failure: ((Error) -> Void)?) {
    guard let instagramDeepLinkUrl = URL(string: "\(self.instagramURL)library?AssetPath=\(url.absoluteString)") else {
      failure?(SKInstagramBroadcastError.deepLinkFailedToOpen)
      return
    }
    
    if UIApplication.shared.canOpenURL(instagramDeepLinkUrl) {
      UIApplication.shared.open(instagramDeepLinkUrl, options: [:], completionHandler: nil)
      success?()
    } else {
      failure?(SKInstagramBroadcastError.deepLinkFailedToOpen)
    }
  }
  
  func assetLibraryUrl(from url: URL?, assetIdentifier identifier: String) -> URL? {
    guard let url = url else { return nil }
    let pathExtension = url.pathExtension
    // I figured that the URL has to look like this (for Instagram sharing) by examining how the asset library URL looks when opening a video using `UIImagePickerController`
    let assetLibraryUrl = "assets-library://asset/asset.\(pathExtension)?id=\(identifier)&ext=\(pathExtension)"
    return URL(string: assetLibraryUrl)
  }
}
