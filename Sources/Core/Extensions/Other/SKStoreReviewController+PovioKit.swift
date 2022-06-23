//
//  SKStoreReviewController+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomažin on 23/06/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import StoreKit

public extension SKStoreReviewController {
  @available(iOS 14.0, *)
  /// Request a review popup on the current scene.
  ///
  /// Example: `SKStoreReviewController.requestReviewInCurrentScene()`
  static func requestReviewInCurrentScene() {
    (UIApplication
      .shared
      .connectedScenes
      .first { $0.activationState == .foregroundActive } as? UIWindowScene
    ).map { requestReview(in: $0) }
  }
}
