//
//  CustomAnimation.swift
//  Demo
//
//  Created by Marko Mijatovic on 4/27/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import UIKit
import PovioKitUI

class CustomAnimation: NSObject, DialogTransitionAnimation {
  var duration: TimeInterval = 0.5
  var presenting: Bool
  var originFrame: CGRect = .zero
  
  init(presenting: Bool = true) {
    self.presenting = presenting
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    if presenting {
      guard let toView = transitionContext.view(forKey: .to) else { return }
      let containerView = transitionContext.containerView
      containerView.addSubview(toView)
      toView.transform = CGAffineTransform(rotationAngle: .pi)
      UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
        toView.transform = .identity
      }, completion: { _ in
        transitionContext.completeTransition(true)
      })
    } else {
      guard let fromView = transitionContext.view(forKey: .from) else { return }
      fromView.transform = .identity
      UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
        fromView.transform = CGAffineTransform(rotationAngle: .pi)
      }, completion: { _ in
        transitionContext.completeTransition(true)
      })
    }
  }
}
