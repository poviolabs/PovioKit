//
//
//  DialogViewModel.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 31/01/2023.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation
import UIKit

public struct DialogViewModel {
  internal let position: DialogPosition
  internal let width: DialogContentWidth
  internal let height: DialogContentHeight
  internal let swipeGestureThreshold: CGFloat
  
  /// DialogViewModel is used to configure Dialog position and alignment on the screen.
  /// - Parameters:
  ///   - position: ``DialogPosition`` value, representing global Dialog position on the screen
  ///   - width: ``DialogContentWidth`` value, representing horizontal dimensions of the Dialog
  ///   - height: ``DialogContentHeight`` value, representing vertical dimensions of the Dialog
  ///   - swipeGestureThreshold: A value that we use for the swipe animation limit to translate content or to return it with animation.
  public init(position: DialogPosition = .bottom,
              width: DialogContentWidth = .normal,
              height: DialogContentHeight = .normal,
              swipeGestureThreshold: CGFloat = 200.0) {
    self.position = position
    self.width = width
    self.height = height
    self.swipeGestureThreshold = swipeGestureThreshold
  }
}

// MARK: - Internal
internal extension DialogViewModel {
  /// Check if the content should be moved with this gesture.
  ///
  /// We will check if the translation **direction** is correct for the current Dialog position value (``DialogPosition``)
  /// and also if the scrollView content is **scrolled to the edge** (top or bottom, depending on the Dialog position value)
  /// - Parameters:
  ///   - translation: CGFloat value representing vertical translation
  ///   - content: ``DialogContentView`` reference
  ///   - sender: ``UIPanGestureRecognizer`` reference
  /// - Returns: *true* if the content should move with the gesture
  func shouldTranslateContent(translation: CGFloat, content: DialogContentView, sender: UIPanGestureRecognizer) -> Bool {
    shouldAnimateTranslation(translation) && scrolledToTheEdge(content, sender: sender)
  }
  
  /// Check if the Dialog should be dismissed with this gesture.
  ///
  /// We will check if the translation is **passed the limit for return animation**
  /// and also if the scrollView content is **scrolled to the edge** (top or bottom, depending on the Dialog position value)
  /// - Parameters:
  ///   - translation: CGFloat value representing vertical translation
  ///   - content: ``DialogContentView`` reference
  ///   - sender: ``UIPanGestureRecognizer`` reference
  /// - Returns: *true* if the Dialog should dismiss
  func shouldDismissOnSwipe(translation: CGFloat, content: DialogContentView, sender: UIPanGestureRecognizer) -> Bool {
    !shouldAnimateReturn(translation) && scrolledToTheEdge(content, sender: sender)
  }
  
  /// Calculate final position for the Dialog.
  /// We will use this to move the content view outside the screen before it is dismissed.
  /// - Parameter translation: CGFloat value representing vertical translation
  /// - Returns: CGFloat value on the Y axis as a final position
  func dismissFinalPosition(_ translation: CGFloat) -> CGFloat {
    translation + swipeAnimationLimit
  }
}

// MARK: - Private
private extension DialogViewModel {
  var swipeAnimationLimit: CGFloat {
    switch position {
    case .bottom, .center:
      return swipeGestureThreshold
    case .top:
      return -swipeGestureThreshold
    }
  }
  
  func shouldAnimateReturn(_ translation: CGFloat) -> Bool {
    switch position {
    case .bottom, .center:
      return translation < swipeAnimationLimit
    case .top:
      return translation > swipeAnimationLimit
    }
  }
  
  func shouldAnimateTranslation(_ translation: CGFloat) -> Bool {
    switch position {
    case .bottom, .center:
      return translation > 0
    case .top:
      return translation < 0
    }
  }
  
  func scrolledToTheEdge(_ contentView: DialogContentView, sender: UIPanGestureRecognizer) -> Bool {
    /// we will not check if content is scrolled to the edge if touch location is outside the scrollView
    guard contentView.scrollView.bounds.contains(sender.location(in: contentView.scrollView)) else {
      return true
    }
    switch position {
    case .bottom, .center:
      return contentView.scrollView.isScrolledAtTop
    case .top:
      return contentView.scrollView.isScrolledAtBottom
    }
  }
}
