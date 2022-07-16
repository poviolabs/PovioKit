//
//  SKStoreReviewControllerTests.swift
//  PovioKit_Tests
//
//  Created by Gentian Barileva on 09/07/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest
@testable import PovioKit
import StoreKit

@available(iOS 14.0, *)
class SKStoreReviewControllerTests: XCTestCase {
  func test_requestReviewInCurrentScene_messagesSceneProvider() {
    let (sceneProvider, reviewProvider) = makeSUT()

    SKStoreReviewController.requestReviewInCurrentScene(sceneProvider: sceneProvider, reviewProvider: reviewProvider)
    
    XCTAssertTrue(sceneProvider.didCallGetGonnectedScene)
  }
  
  func test_requestReviewInCurrentScene_sendsCorrectSceneToReviewProvider() {
    let scene = anyScene(activationState: .foregroundActive)
    let (sceneProvider, reviewProvider) = makeSUT(scenes: [scene])
    
    SKStoreReviewController.requestReviewInCurrentScene(sceneProvider: sceneProvider, reviewProvider: reviewProvider)
    
    
    XCTAssertTrue(reviewProvider.capturedScene?.activationState == scene.activationState)
  }
  
  func test_requestReviewInCurrentScene_sceneProviderDoesntMessageReviewProviderOnInvalidActivationStates() {
    let scenes = [anyScene(activationState: .unattached), anyScene(activationState: .background), anyScene(activationState: .foregroundInactive), anyScene(activationState: .unattached)]
    let (sceneProvider, reviewProvider) = makeSUT(scenes: scenes)
    
    SKStoreReviewController.requestReviewInCurrentScene(sceneProvider: sceneProvider, reviewProvider: reviewProvider)
    
    XCTAssertNil(reviewProvider.capturedScene)
  }
  
  func test_requestReviewInCurrentScene_sceneProviderDoesntMessageReviewProviderOnEmptyScenes() {
    let (sceneProvider, reviewProvider) = makeSUT()

    SKStoreReviewController.requestReviewInCurrentScene(sceneProvider: sceneProvider, reviewProvider: reviewProvider)
    
    XCTAssertTrue(sceneProvider.scenes.isEmpty)
    XCTAssertNil(reviewProvider.capturedScene)
  }
}

// MARK: - Helpers
@available(iOS 14.0, *)
private extension SKStoreReviewControllerTests {
  func makeSUT(scenes: [Scene] = []) -> (sceneProvider: MockSceneProvider, reviewProvider: MockReviewProvider) {
    let sceneProvider = MockSceneProvider(scenes: scenes)
    let reviewProvider = MockReviewProvider()

    return (sceneProvider, reviewProvider)
  }
  
  func anyScene(activationState: UIScene.ActivationState) -> Scene {
    Scene(ui: nil, activationState: activationState)
  }
}

@available(iOS 14.0, *)
private class MockSceneProvider: SceneProviding {
  var scenes: [Scene] = []
  private(set) var didCallGetGonnectedScene = false
  public init(scenes: [Scene]) {
    self.scenes = scenes
  }

  func getConnectedScenes() -> [Scene] {
    didCallGetGonnectedScene = true
    return scenes
  }
}

@available(iOS 14.0, *)
private class MockReviewProvider: RequestReviewProviding {
  var capturedScene: Scene?
  
  func requestReview(in scene: Scene?) {
    capturedScene = scene
  }
}
