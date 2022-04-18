//
//  BottomSheetAnimators+Demo.swift
//  Demo
//
//  Created by Marko Mijatovic on 18/04/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation
import PovioKitUI
import UIKit

extension BottomSheet.AnimatorFactory {
  static func myAnimation(
    animationDuration: TimeInterval,
    withDelay delay: TimeInterval = 0
  ) -> Animator {
    { current, next in
      next.transform = CGAffineTransform.identity.rotated(by: 30)
      UIView.animate(
        withDuration: animationDuration,
        delay: delay,
        animations: {
          next.transform = .identity
          current.transform = CGAffineTransform.identity.rotated(by: 30)
        }
      )
    }
  }
}
