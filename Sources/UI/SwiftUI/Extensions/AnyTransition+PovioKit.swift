//
//  AnyTransition+PovioKit.swift
//  PovioKit
//
//  Created by Arlind Dushi on 3/22/22.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import SwiftUI

public extension AnyTransition {
  /// `slideLeft` is a inverse transition of system `slide`
  static var slideLeft: AnyTransition {
    .asymmetric(
      insertion: .move(edge: .trailing),
      removal: .move(edge: .leading)
    )
  }
}
