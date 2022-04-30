//
//  DialogTransitionAnimation.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 4/19/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import UIKit

/// Predefined Dialog animation types
public enum DialogAnimationType {
  case fade
  case flip
  case pushPop
  case custom(DialogTransitionAnimation)
}

/// Protocol that defines Dailog animations.
///
/// Use it when creating custom transition animation.
public protocol DialogTransitionAnimation: UIViewControllerAnimatedTransitioning {
  
  /// Animation duration in seconds
  var duration: TimeInterval { get set }
  
  /// Flag that indicates UIViewControllerAnimatedTransitioning state: presenting or dismissing
  var presenting: Bool { get set }
  
  /// CGRect of the origin UIViewController, use it if needed for custom animations
  var originFrame: CGRect { get set }
}
