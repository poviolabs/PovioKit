//
//  DialogPosition.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 4/19/22.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation

/// Dialog position on the screen
public enum DialogPosition {
  case bottom
  case top
  case center
}

// MARK: - Internal
internal extension DialogPosition {
  var swipeAnimationLimit: CGFloat {
    switch self {
    case .bottom, .center:
      return swipeAnimationLimitConstant
    case .top:
      return -swipeAnimationLimitConstant
    }
  }
  
  func shouldAnimateReturn(_ value: CGFloat) -> Bool {
    switch self {
    case .bottom, .center:
      return value < swipeAnimationLimit
    case .top:
      return value > swipeAnimationLimit
    }
  }
  
  func shouldAnimateTranslation(_ translation: Double) -> Bool {
    switch self {
    case .bottom, .center:
      return translation > 0
    case .top:
      return translation < 0
    }
  }
}

// MARK: - Private
private extension DialogPosition {
  var swipeAnimationLimitConstant: CGFloat { 300 }
}
