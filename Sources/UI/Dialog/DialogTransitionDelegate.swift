//
//  DialogTransitionDelegate.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 4/19/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import UIKit

internal class DialogTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
  let animation: DialogAnimationType?
  
  init(animation: DialogAnimationType? = .none) {
    self.animation = animation
  }
  
  func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return getAnimation(presenting: true)
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return getAnimation(presenting: false)
  }
}

private extension DialogTransitionDelegate {
  
  /// Get DialogTransitionAnimation for presenting or dismissing
  /// - Parameter presenting: true if presenting, false for dismissing
  /// - Returns: ``DialogTransitionAnimation`` from provided ``DialogAnimationType`` (**can be nil**)
  func getAnimation(presenting: Bool) -> DialogTransitionAnimation? {
    switch animation {
    case .fade:
      return FadeAnimation(presenting: presenting)
    case .flip:
      return FlipAnimation(presenting: presenting)
    case .pushPop:
      return PushPopAnimation(presenting: presenting)
    case .custom(let animator):
      animator.presenting = presenting
      return animator
    case .none:
      return .none
    }
  }
}
