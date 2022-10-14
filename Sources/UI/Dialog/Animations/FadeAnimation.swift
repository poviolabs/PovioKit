//
//  FadeAnimation.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 4/26/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import UIKit

class FadeAnimation: NSObject {
  var duration: TimeInterval = DialogConstants.animationDuration
  var presenting: Bool
  var originFrame: CGRect = .zero
  
  init(presenting: Bool = true) {
    self.presenting = presenting
  }
}
  
extension FadeAnimation: DialogTransitionAnimation {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    if presenting {
      guard let toView = transitionContext.view(forKey: .to) else { return }
      let containerView = transitionContext.containerView
      containerView.addSubview(toView)
      toView.alpha = 0.0
      UIView.animate(withDuration: duration, animations: {
        toView.alpha = 1.0
      }, completion: { _ in
        transitionContext.completeTransition(true)
      })
    } else {
      guard let fromView = transitionContext.view(forKey: .from) else { return }
      fromView.alpha = 1.0
      UIView.animate(withDuration: duration, animations: {
        fromView.alpha = 0.0
      }, completion: { _ in
        transitionContext.completeTransition(true)
      })
    }
  }
}
