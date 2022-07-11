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

@available(iOS 14.0, *)
public struct Scene {
    let ui: UIScene?
    let activationState: UIWindowScene.ActivationState
}

@available(iOS 14.0, *)
class SKStoreReviewControllerTests: XCTestCase {
  func test_requestReviewInCurrentScene_messagesSceneProvider() {
    let (sceneProvider, reviewProvider) = makeSUT()

    tempRequestReviewInCurrentScene(sceneProvider: sceneProvider, reviewProvider: reviewProvider)
    
    XCTAssertTrue(sceneProvider.didCallGetGonnectedScene)
  }
@available(iOS 14.0, *)
private extension SKStoreReviewControllerTests {
  func makeSUT(scene: Scene? = nil) -> (sceneProvider: MockSceneProvider, reviewProvider: MockReviewProvider) {
    let sceneProvider = MockSceneProvider(scene: scene)
    let reviewProvider = MockReviewProvider()

    return (sceneProvider, reviewProvider)
  }
}

@available(iOS 14.0, *)
private class MockSceneProvider: SceneProviding {
  var scene: Scene?
  private(set) var didCallGetGonnectedScene = false
  public init() {}

  func getConnectedScene() -> Scene? {
    didCallGetGonnectedScene = true
    return nil
  }
}

@available(iOS 14.0, *)
private class MockReviewProvider: RequestReviewProviding {
  func requestReview(in scene: Scene?) { }
}
