//
//  SKStoreReviewControllerTests.swift
//  PovioKit_Tests
//
//  Created by Gentian Barileva on 09/07/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest

@available(iOS 14.0, *)
public protocol RequestReviewProviding {
  func requestReview(in scene: Scene?)
}

@available(iOS 14.0, *)
public protocol SceneProviding {
  func getConnectedScene() -> Scene?
}

@available(iOS 14.0, *)
func tempRequestReviewInCurrentScene(sceneProvider: SceneProviding, reviewProvider: RequestReviewProviding) {
  let scene = sceneProvider.getConnectedScene()
  reviewProvider.requestReview(in: scene)
}
class SKStoreReviewControllerTests: XCTestCase {
  
}
