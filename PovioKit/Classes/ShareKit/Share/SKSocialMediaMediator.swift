//
//  SKSocialMediaMediator.swift
//  PovioKit
//
//  Created by Toni Kocjan on 37/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import UIKit

public enum SKSocialMediaError: Error {
  case userCanceled
  case applicationNotInstalled(String)
  case unknown
  
  var localizedDescription: String {
    switch self {
    case .userCanceled:
      return "User canceled operation!"
    case .applicationNotInstalled(let application):
      return "Required application [\(application)] not installed!"
    case .unknown:
      return "An unknown error occured!"
    }
  }
}

public protocol SKSocialMediaBroadcast: class {
  func sharePost(_ post: SKSocialMediaPost, from viewController: UIViewController, success: (() -> Void)?, failure: ((Error) -> Void)?)
  var delegate: SKSocialMediaMediatorDelegate? { get set }
}

public protocol SKSocialMediaMediatorDelegate: class {
  func didBeginLoading(socialMediaBroadcast broadcast: SKSocialMediaBroadcast)
  func didFinishLoading(socialMediaBroadcast broadcast: SKSocialMediaBroadcast)
}

class SKSocialMediaMediator {
  private var broadcast: SKSocialMediaBroadcast? // need to keep a strong reference, otherwise an instance will get immediately deinitialized, which means that the delegates inside the `broadcast` wouldn't get called!
  weak var delegate: SKSocialMediaMediatorDelegate?
  let factory: SKSocialMediaBroadcastFactory
  
  init(factory: SKSocialMediaBroadcastFactory, delegate: SKSocialMediaMediatorDelegate?) {
    self.factory = factory
    self.delegate = delegate
  }
  
  func sharePost(_ post: SKSocialMediaPost, on socialMedia: SKSocialMediaKind, from viewController: UIViewController, success: (() -> Void)?, failure: ((Error) -> Void)?) {
    let broadcast = factory.broadcast(on: socialMedia)
    self.broadcast = broadcast
    broadcast.delegate = delegate
    broadcast.sharePost(post, from: viewController, success: { [weak self] in
      self?.broadcast = nil // prevent memory leak
      success?()
    }, failure: { [weak self] error in
      self?.broadcast = nil // prevent memory leak
      failure?(error)
    })
  }
}
