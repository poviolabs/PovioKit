//
//  WizardAnimators.swift
//  PovioKit
//
//  Created by Toni Kocjan on 29/09/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import UIKit

public extension Wizard {
  enum AnimatorFactory {
    public typealias Animator = (UIView, UIView) -> Void
  }
}

public extension Wizard.AnimatorFactory {
  static func SlideInSlideOut(
    animationDuration: TimeInterval,
    withDelay delay: TimeInterval = 0
  ) -> Animator {
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
  
  static func FadeIn(
    animationDuration: TimeInterval,
    withDelay delay: TimeInterval = 0
  ) -> Animator {
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
  
  static func FadeOut(
    animationDuration: TimeInterval,
    withDelay delay: TimeInterval = 0
  ) -> Animator {
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
  
  static func FadeInFadeOut(
    animationDuration: TimeInterval,
    withDelay delay: TimeInterval = 0
  ) -> Animator {
    Composite(
      animators:
        [
          FadeIn(animationDuration: animationDuration, withDelay: delay),
          FadeOut(animationDuration: animationDuration, withDelay: delay)
        ]
    )
  }
  
  static func PopInPopOut(
    animationDuration: TimeInterval,
    withDelay delay: TimeInterval = 0
  ) -> Animator {
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
  
  static func Composite<C: Collection>(
    animators: C
  ) -> Animator where C.Element == Animator {
    { current, next in
      animators.forEach { $0(current, next) }
    }
  }
  
  static func Composite(
    animators: Animator...
  ) -> Animator {
    { current, next in
      animators.forEach { $0(current, next) }
    }
  }
}
