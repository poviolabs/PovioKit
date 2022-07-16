//
//  SKStoreReviewController+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomažin on 23/06/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import StoreKit

@available(iOS 14.0, *)
public extension SKStoreReviewController {
  /// Request a review popup on the current scene.
  ///
  /// Example: `SKStoreReviewController.requestReviewInCurrentScene()`
  static func requestReviewInCurrentScene(sceneProvider: SceneProviding = UIApplicationSceneProvider(),
                                          reviewProvider: RequestReviewProviding = SKStoreReviewProvider()) {
    let sceneManager = SceneManager(provider: sceneProvider)
    let activeScene = sceneManager.getActiveScene()
    reviewProvider.requestReview(in: activeScene)
  }
  
  private struct SceneManager {
    private let provider: SceneProviding
    
    public init(provider: SceneProviding) {
      self.provider = provider
    }
    
    func getActiveScene() -> Scene? {
      provider.getConnectedScenes()
        .first(where: { $0.activationState == .foregroundActive })
    }
  }
}

// MARK: Helpers
@available(iOS 14.0, *)
public extension SKStoreReviewController {
  struct SKStoreReviewProvider: RequestReviewProviding {
    public init() { }
    
    public func requestReview(in scene: Scene?) {
      if let scene = scene?.ui as? UIWindowScene {
        SKStoreReviewController.requestReview(in: scene)
      }
    }
  }
  
  struct UIApplicationSceneProvider: SceneProviding {
    private let connectedScenes = UIApplication.shared.connectedScenes
    
    public init() { }
    
    public func getConnectedScenes() -> [Scene] {
      connectedScenes
        .map { Scene(ui: $0, activationState: $0.activationState) }
    }
  }
}

@available(iOS 14.0, *)
public struct Scene {
    let ui: UIScene?
    let activationState: UIWindowScene.ActivationState
}
