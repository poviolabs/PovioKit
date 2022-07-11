//
//  SKStoreReviewControllerTests.swift
//  PovioKit_Tests
//
//  Created by Gentian Barileva on 09/07/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest
import StoreKit

@available(iOS 14.0, *)
public protocol RequestReviewProviding {
  func requestReview(in scene: Scene?)
}

@available(iOS 14.0, *)
public protocol SceneProviding {
  func getConnectedScene() -> Scene?
}

@available(iOS 14.0, *)
public struct UIApplicationSceneProvider: SceneProviding {
  private let connectedScenes = UIApplication.shared.connectedScenes
  
  public func getConnectedScene() -> Scene? {
    connectedScenes
      .first(where: { $0.activationState == .foregroundActive })
      .map { Scene(ui: $0, activationState: $0.activationState) }
  }
}

@available(iOS 14.0, *)
public struct SKStoreReviewProvider: RequestReviewProviding {
  public func requestReview(in scene: Scene?) {
    if let scene = scene?.ui as? UIWindowScene {
      SKStoreReviewController.requestReview(in: scene)
    }
  }
}

@available(iOS 14.0, *)
func tempRequestReviewInCurrentScene(sceneProvider: SceneProviding = UIApplicationSceneProvider(), reviewProvider: RequestReviewProviding) {
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
  
  func test_requestReviewInCurrentScene_sendsCorrectSceneToReviewProvider() {
    let scene = anyScene(activationState: .foregroundActive)
    let (sceneProvider, reviewProvider) = makeSUT(scenes: [scene])
    
    tempRequestReviewInCurrentScene(sceneProvider: sceneProvider, reviewProvider: reviewProvider)
    
    XCTAssertTrue(reviewProvider.capturedScene?.activationState == scene.activationState)
  }
  
  func test_requestReviewInCurrentScene_sceneProviderDoesntMessageReviewProviderOnInvalidActivationStates() {
    let scenes = [anyScene(activationState: .unattached), anyScene(activationState: .background), anyScene(activationState: .foregroundInactive), anyScene(activationState: .unattached)]
    let (sceneProvider, reviewProvider) = makeSUT(scenes: scenes)
    
    tempRequestReviewInCurrentScene(sceneProvider: sceneProvider, reviewProvider: reviewProvider)
    
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

  func getConnectedScene() -> Scene? {
    didCallGetGonnectedScene = true
    return scenes.first(where: { $0.activationState == .foregroundActive })
  }
}

@available(iOS 14.0, *)
private class MockReviewProvider: RequestReviewProviding {
  var capturedScene: Scene?
  
  func requestReview(in scene: Scene?) {
    capturedScene = scene
  }
}
