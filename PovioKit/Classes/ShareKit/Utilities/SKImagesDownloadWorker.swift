//
//  SKAsyncImagesDownloadWorker.swift
//  PovioKit
//
//  Created by Toni Kocjan on 37/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import UIKit

protocol SKAssetDownloaderProtocol {
  func downloadImage(from url: URL, success: ((UIImage) -> Void)?, failure: ((Error) -> Void)?)
  func downloadVideo(from url: URL, success: ((Data) -> Void)?, failure: ((Error) -> Void)?)
}

protocol SKImagesDownloadWorker {
  func downloadImages(urls: [URL], success: (([UIImage]) -> Void)?, failure: ((Error) -> Void)?)
}

class SKAsyncImagesDownloadWorker: SKImagesDownloadWorker {
  let assetDownloader: SKAssetDownloaderProtocol
  
  init(assetDownloader: SKAssetDownloaderProtocol) {
    self.assetDownloader = assetDownloader
  }
  
  func downloadImages(urls: [URL], success: (([UIImage]) -> Void)?, failure: ((Error) -> Void)?) {
    var images = [UIImage]()
    var responseError: Error?
    let dispatchGroup = DispatchGroup()
    
    urls.forEach {
      dispatchGroup.enter()
      self.assetDownloader.downloadImage(from: $0, success: { image in
        images.append(image)
        dispatchGroup.leave()
      }, failure: { error in
        responseError = error
        dispatchGroup.suspend()
        dispatchGroup.leave()
      })
    }
    
    dispatchGroup.notify(queue: .main) {
      if let error = responseError {
        failure?(error)
        return
      }
      success?(images)
    }
  }
}
