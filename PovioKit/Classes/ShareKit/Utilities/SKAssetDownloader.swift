//
//  SKAssetDownloader.swift
//  PovioKit
//
//  Created by Toni Kocjan on 17/12/2018.
//

import Foundation

public protocol SKAssetDownloaderProtocol {
  func downloadImage(from url: URL, success: ((UIImage) -> Void)?, failure: ((Error) -> Void)?)
  func downloadVideo(from url: URL, success: ((Data) -> Void)?, failure: ((Error) -> Void)?)
}

struct SKAssetDownloader: SKAssetDownloaderProtocol {
  func downloadImage(from url: URL, success: ((UIImage) -> Void)?, failure: ((Error) -> Void)?) {
    DispatchQueue.main.async {
      do {
        let data = try Data(contentsOf: url)
        if let image = UIImage(data: data) {
          success?(image)
        } else {
          failure?(SKSocialMediaError.unknown)
        }
      } catch {
        failure?(error)
      }
    }
  }
  
  func downloadVideo(from url: URL, success: ((Data) -> Void)?, failure: ((Error) -> Void)?) {
    DispatchQueue.main.async {
      do {
        let data = try Data(contentsOf: url)
        success?(data)
      } catch {
        failure?(error)
      }
    }
  }
}
