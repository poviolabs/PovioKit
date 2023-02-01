//
//
//  DialogViewModel.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 31/01/2023.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation

public struct DialogViewModel {
  let position: DialogPosition
  let width: DialogContentWidth
  let height: DialogContentHeight
  
  public init(position: DialogPosition = .bottom,
       width: DialogContentWidth = .normal,
       height: DialogContentHeight = .normal) {
    self.position = position
    self.width = width
    self.height = height
  }
}

// MARK: - Internal
internal extension DialogViewModel {
  var swipeAnimationLimit: CGFloat {
    switch position {
    case .bottom, .center:
      return swipeAnimationLimitConstant
    case .top:
      return -swipeAnimationLimitConstant
    }
  }
  
  func shouldAnimateReturn(_ value: CGFloat) -> Bool {
    switch position {
    case .bottom, .center:
      return value < swipeAnimationLimit
    case .top:
      return value > swipeAnimationLimit
    }
  }
  
  func shouldAnimateTranslation(_ translation: Double) -> Bool {
    switch position {
    case .bottom, .center:
      return translation > 0
    case .top:
      return translation < 0
    }
  }
}

// MARK: - Private
private extension DialogViewModel {
  var swipeAnimationLimitConstant: CGFloat { 100 }
}
