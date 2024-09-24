//
//  BlurBackgroundModifier.swift
//  PovioKit
//
//  Created by Borut Tomazin on 24/09/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if os(macOS)
import SwiftUI

struct BlurBackgroundModifier: ViewModifier {
  var material: NSVisualEffectView.Material = .hudWindow
  var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
  
  func body(content: Content) -> some View {
    content.background(BlurView(material: material, blendingMode: blendingMode))
  }
}

extension View {
  func blurBackground(
    material: NSVisualEffectView.Material = .hudWindow,
    blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
  ) -> some View {
    modifier(BlurBackgroundModifier())
  }
}
#endif
