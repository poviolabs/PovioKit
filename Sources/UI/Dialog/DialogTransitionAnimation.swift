//
//  DialogTransitionAnimation.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 4/19/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import UIKit

public enum DialogAnimationType {
  case fade
  case flip
  case pushPop
  case custom(DialogTransitionAnimation)
}

public protocol DialogTransitionAnimation: UIViewControllerAnimatedTransitioning {
  var duration: TimeInterval { get set }
  var presenting: Bool { get set }
  var originFrame: CGRect { get set }
}
