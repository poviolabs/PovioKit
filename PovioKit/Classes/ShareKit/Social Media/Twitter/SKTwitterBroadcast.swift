//
//  TwitterBroadcast.swift
//  Facelift
//
//  Created by Toni Kocjan on 17/07/2018.
//  Copyright © 2018 poviolabs. All rights reserved.
//

import TwitterKit

class SKTwitterBroadcast: NSObject, SKSocialMediaBroadcast {
  private var success: (() -> Void)?
  private var failure: ((Error) -> Void)?
  private let assetDownloader: SKAssetDownloaderProtocol
  weak var delegate: SKSocialMediaMediatorDelegate?
  
  init(assetDownloader: SKAssetDownloaderProtocol) {
    self.assetDownloader = assetDownloader
  }
  
  func sharePost(_ post: SKSocialMediaPost, from viewController: UIViewController, success: (() -> Void)?, failure: ((Error) -> Void)?) {
    self.success = success
    self.failure = failure
    
    guard let imageUrl = post.imageUrls.first else {
      presentComposer(on: viewController,
                      initialText: post.content,
                      image: nil,
                      videoURL: post.videoUrls.first)
      return
    }
    
    delegate?.didBeginLoading(socialMediaBroadcast: self)
    assetDownloader.downloadImage(from: imageUrl, success: { image in
      self.delegate?.didFinishLoading(socialMediaBroadcast: self)
      self.presentComposer(on: viewController,
                           initialText: post.content,
                           image: image,
                           videoURL: post.videoUrls.first)
    }, failure: { error in
      self.delegate?.didFinishLoading(socialMediaBroadcast: self)
      self.failure?(error)
    })
  }
}

extension SKTwitterBroadcast: TWTRComposerViewControllerDelegate {
  func composerDidSucceed(_ controller: TWTRComposerViewController, with tweet: TWTRTweet) {
    success?()
    success = nil
  }
  
  func composerDidCancel(_ controller: TWTRComposerViewController) {
    failure?(SKSocialMediaError.userCanceled)
    failure = nil
  }
  
  func composerDidFail(_ controller: TWTRComposerViewController, withError error: Error) {
    failure?(error)
    failure = nil
  }
}

private extension SKTwitterBroadcast {
  func presentComposer(on viewController: UIViewController, initialText: String, image: UIImage?, videoURL: URL?) {
    let composer = TWTRComposerViewController(initialText: initialText,
                                              image: image,
                                              videoURL: videoURL)
    composer.delegate = self
    viewController.present(composer, animated: true, completion: nil)
    delegate?.didFinishLoading(socialMediaBroadcast: self)
  }
}
