//
//  SKFacebookBroadcast.swift
//  PovioKit
//
//  Created by Toni Kocjan on 37/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import FBSDKShareKit

class SKFacebookBroadcast: NSObject, SKSocialMediaBroadcast {
  private let authenticator: SKFacebookAuthenticator
  private let assetLibraryProvider: SKAssetLibraryFacade
  private let imagesDownloader: SKImagesDownloadWorker
  private var success: (() -> Void)?
  private var failure: ((Error) -> Void)?
  weak var delegate: SKSocialMediaMediatorDelegate?
  
  init(authenticator: SKFacebookAuthenticator, assetLibraryProvider: SKAssetLibraryFacade, imagesDownloader: SKImagesDownloadWorker) {
    self.authenticator = authenticator
    self.assetLibraryProvider = assetLibraryProvider
    self.imagesDownloader = imagesDownloader
  }
  
  func sharePost(_ post: SKSocialMediaPost, from viewController: UIViewController, success: (() -> Void)?, failure: ((Error) -> Void)?) {
    self.success = success
    self.failure = failure
    
    if authenticator.isApplicationInstalled && isMediaShareAllowed(for: post) {
      shareMediaPost(post, from: viewController)
    } else {
      guard let _ = post.url else {
        failure?(SKSocialMediaError.applicationNotInstalled("facebook"))
        return
      }
      shareLinkPost(post, from: viewController)
    }
  }
  
  func shareMediaPost(_ post: SKSocialMediaPost, from viewController: UIViewController) {
    // note: media share is not possible if app is not installed
    
    delegate?.didBeginLoading(socialMediaBroadcast: self)
    
    var media: [Any] = []
    let dispatchGroup = DispatchGroup()
    
    if let videoUrl = post.videoUrls.first {
      dispatchGroup.enter()
      self.assetLibraryProvider.saveVideo(fromUrl: videoUrl, success: { asset, _ in
        let video = FBSDKShareVideo()
        video.videoAsset = asset
        media.append(video)
        dispatchGroup.leave()
      }, failure: { error in
        dispatchGroup.leave()
        self.failure?(error)
        self.delegate?.didFinishLoading(socialMediaBroadcast: self)
      })
    }
    
    dispatchGroup.enter()
    imagesDownloader.downloadImages(urls: post.imageUrls, success: { images in
      dispatchGroup.leave()
      images.forEach {
        let photo = FBSDKSharePhoto()
        photo.image = $0
        photo.isUserGenerated = true
        media.append(photo)
      }
    }, failure: { error in
      dispatchGroup.leave()
      self.failure?(error)
      self.delegate?.didFinishLoading(socialMediaBroadcast: self)
    })
    
    dispatchGroup.notify(queue: .main) {
      let content = FBSDKShareMediaContent()
      content.media = media
      self.showDialog(content: content, from: viewController)
      self.delegate?.didFinishLoading(socialMediaBroadcast: self)
    }
  }
  
  func shareLinkPost(_ post: SKSocialMediaPost, from viewController: UIViewController) {
    let content = FBSDKShareLinkContent()
    content.contentURL = post.url
    showDialog(content: content, from: viewController)
    delegate?.didFinishLoading(socialMediaBroadcast: self)
  }
}

// MARK: - FBSDKSharingDelegate
extension SKFacebookBroadcast: FBSDKSharingDelegate {
  func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
    success?()
    success = nil
  }
  
  func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
    failure?(error)
    failure = nil
  }
  
  func sharerDidCancel(_ sharer: FBSDKSharing!) {
    failure?(SKSocialMediaError.userCanceled)
    failure = nil
  }
}

private extension SKFacebookBroadcast {
  func showDialog(content: FBSDKSharingContent, from viewController: UIViewController) {
    let dialog = FBSDKShareDialog()
    dialog.shareContent = content
    dialog.fromViewController = viewController
    dialog.delegate = self
    dialog.show()
  }
  
  func isMediaShareAllowed(for post: SKSocialMediaPost) -> Bool {
    return !(post.imageUrls.isEmpty && post.videoUrls.isEmpty)
  }
}
