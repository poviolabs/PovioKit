//
//  FlipAnimation.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 4/26/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import UIKit

class FlipAnimation: NSObject {
  var duration: TimeInterval = 0.5
  var presenting: Bool
  var originFrame: CGRect = .zero
  
  init(presenting: Bool = true) {
    self.presenting = presenting
  }
}

extension FlipAnimation: DialogTransitionAnimation {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    presenting ? present(using: transitionContext) : dismiss(using: transitionContext)
  }
}

private extension FlipAnimation {
  func present(using transitionContext: UIViewControllerContextTransitioning) {
    guard let toVC = transitionContext.viewController(forKey: .to) else { return }
    
    let containerView = transitionContext.containerView
    containerView.addSubview(toVC.view)
    
    perspectiveTransform(for: containerView)
    toVC.view.layer.transform = yRotation(.pi / 2)
    
    UIView.animate(withDuration: duration, animations: {
      toVC.view.layer.transform = self.yRotation(0.0)
    }, completion: { _ in
      transitionContext.completeTransition(true)
    })
  }
  
  func dismiss(using transitionContext: UIViewControllerContextTransitioning) {
    guard let fromVC = transitionContext.viewController(forKey: .from) else { return }
    
    let containerView = transitionContext.containerView
    perspectiveTransform(for: containerView)
    fromVC.view.layer.transform = yRotation(0.0)
    
    UIView.animate(withDuration: duration, animations: {
      fromVC.view.layer.transform = self.yRotation(.pi / 2)
    }, completion: { _ in
      transitionContext.completeTransition(true)
    })
  }
  
  func yRotation(_ angle: Double) -> CATransform3D {
    return CATransform3DMakeRotation(CGFloat(angle), 0.0, 1.0, 0.0)
  }
  
  func perspectiveTransform(for containerView: UIView) {
    var transform = CATransform3DIdentity
    transform.m34 = -0.002
    containerView.layer.sublayerTransform = transform
  }
}
