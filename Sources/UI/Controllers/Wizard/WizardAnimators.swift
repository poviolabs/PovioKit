//
//  WizardAnimators.swift
//  PovioKit
//
//  Created by Toni Kocjan on 29/09/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import UIKit

public typealias WizardTransitionAnimator = ((UIView, UIView) -> Void)

public func SlideInSlideOutAnimatorFactory(animationDuration: TimeInterval) -> WizardTransitionAnimator {
  { current, next in
    next.transform = CGAffineTransform.identity.translatedBy(x: current.frame.width, y: 0)
    UIView.animate(
      withDuration: animationDuration,
      animations: {
        next.transform = .identity
        current.transform = CGAffineTransform.identity.translatedBy(x: -current.frame.width, y: 0)
      }
    )
  }
}

public func FadeInAnimatorFactory(animationDuration: TimeInterval) -> WizardTransitionAnimator {
  { current, next in
    next.alpha = 0
    UIView.animate(
      withDuration: animationDuration,
      animations: {
        next.alpha = 1
      }
    )
  }
}

public func FadeOutAnimatorFactory(animationDuration: TimeInterval) -> WizardTransitionAnimator {
  { current, next in
    UIView.animate(
      withDuration: animationDuration,
      animations: {
        current.alpha = 0
      }
    )
  }
}

public func FadeInFadeOutAnimatorFactory(animationDuration: TimeInterval) -> WizardTransitionAnimator {
  CompositeAnimator(
    animators:
      [
        FadeInAnimatorFactory(animationDuration: animationDuration),
        FadeOutAnimatorFactory(animationDuration: animationDuration)
      ]
  )
}

public func PopInPopOutAnimatorFactory(animationDuration: TimeInterval) -> WizardTransitionAnimator {
  { current, next in
    next.transform = .identity.scaledBy(x: 2, y: 2)
    UIView.animate(
      withDuration: animationDuration,
      animations: {
        next.transform = .identity
        current.transform = .identity.scaledBy(x: 0.01, y: 0.01)
      }
    )
  }
}

public func CompositeAnimator<C: Collection>(
  animators: C
) -> WizardTransitionAnimator where C.Element == WizardTransitionAnimator {
  { current, next in
    animators.forEach { $0(current, next) }
  }
}

public func CompositeAnimator(
  animators: WizardTransitionAnimator...
) -> WizardTransitionAnimator {
  { current, next in
    animators.forEach { $0(current, next) }
  }
}
