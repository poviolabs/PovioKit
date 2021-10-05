//
//  WizardAnimators.swift
//  PovioKit
//
//  Created by Toni Kocjan on 29/09/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import UIKit

public typealias WizardTransitionAnimator = ((UIView, UIView) -> Void)

public func SlideInSlideOutAnimatorFactory(
  animationDuration: TimeInterval,
  withDelay delay: TimeInterval = 0
) -> WizardTransitionAnimator {
  { current, next in
    next.transform = CGAffineTransform.identity.translatedBy(x: current.frame.width, y: 0)
    UIView.animate(
      withDuration: animationDuration,
      delay: delay,
      animations: {
        next.transform = .identity
        current.transform = CGAffineTransform.identity.translatedBy(x: -current.frame.width, y: 0)
      }
    )
  }
}

public func FadeInAnimatorFactory(
  animationDuration: TimeInterval,
  withDelay delay: TimeInterval = 0
) -> WizardTransitionAnimator {
  { current, next in
    next.alpha = 0
    UIView.animate(
      withDuration: animationDuration,
      delay: delay,
      animations: {
        next.alpha = 1
      }
    )
  }
}

public func FadeOutAnimatorFactory(
  animationDuration: TimeInterval,
  withDelay delay: TimeInterval = 0
) -> WizardTransitionAnimator {
  { current, next in
    UIView.animate(
      withDuration: animationDuration,
      delay: delay,
      animations: {
        current.alpha = 0
      }
    )
  }
}

public func FadeInFadeOutAnimatorFactory(
  animationDuration: TimeInterval,
  withDelay delay: TimeInterval = 0
) -> WizardTransitionAnimator {
  CompositeAnimator(
    animators:
      [
        FadeInAnimatorFactory(animationDuration: animationDuration, withDelay: delay),
        FadeOutAnimatorFactory(animationDuration: animationDuration, withDelay: delay)
      ]
  )
}

public func PopInPopOutAnimatorFactory(
  animationDuration: TimeInterval,
  withDelay delay: TimeInterval = 0
) -> WizardTransitionAnimator {
  { current, next in
    next.transform = .identity.scaledBy(x: 2, y: 2)
    UIView.animate(
      withDuration: animationDuration,
      delay: delay,
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
