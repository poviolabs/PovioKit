//
//  SquaredModifier.swift
//  PovioKit
//
//  Created by Borut Tomazin on 10/02/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

struct SquaredModifier: ViewModifier {
  var cornerRadius: CGFloat = 0
  var aspectRatio: CGFloat = 1
  
  func body(content: Content) -> some View {
    content
      .frame(
        minWidth: 0,
        maxWidth: .infinity,
        minHeight: 0,
        maxHeight: .infinity
      )
      .aspectRatio(aspectRatio, contentMode: .fit)
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
  }
}

extension View {
  /// Makes view squared
  func squared(cornerRadius: CGFloat = 0, aspectRatio: CGFloat = 1) -> some View {
    modifier(SquaredModifier(cornerRadius: cornerRadius, aspectRatio: aspectRatio))
  }
}
