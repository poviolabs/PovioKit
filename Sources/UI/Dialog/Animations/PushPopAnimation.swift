//
//  PushPopAnimation.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 4/26/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import UIKit

class PushPopAnimation: NSObject {
  var duration: TimeInterval = 0.5
  var presenting: Bool = true
  var originFrame: CGRect = .zero

  init(presenting: Bool) {
    self.presenting = presenting
  }
}

extension PushPopAnimation: DialogTransitionAnimation {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    duration
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let animatedView: UIView
    var destinationFrame: CGRect
    let containerView = transitionContext.containerView

    if presenting {
      guard let destinationVC = transitionContext.viewController(forKey: .to),
            let toView = transitionContext.view(forKey: .to) else { return }
      animatedView = toView
      animatedView.frame = CGRect(x: animatedView.frame.width,
                                  y: 0.0,
                                  width: animatedView.frame.width,
                                  height: animatedView.frame.height)
      destinationFrame = transitionContext.finalFrame(for: destinationVC)
      containerView.addSubview(animatedView)
    } else {
      guard let fromView = transitionContext.view(forKey: .from) else { return }
      animatedView = fromView
      destinationFrame = CGRect(x: animatedView.frame.width,
                                y: 0.0,
                                width: animatedView.frame.width,
                                height: animatedView.frame.height)
      containerView.addSubview(animatedView)
    }

    UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
      animatedView.frame = destinationFrame
    }, completion: {
      transitionContext.completeTransition($0)
    })
  }
}

