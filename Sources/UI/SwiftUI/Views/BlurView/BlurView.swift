//
//  BlurView.swift
//  PovioKit
//
//  Created by Borut Tomazin on 24/09/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if os(macOS)
import AppKit
import SwiftUI

public struct BlurView: NSViewRepresentable {
  var material: NSVisualEffectView.Material = .hudWindow
  var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
  
  public init(
    material: NSVisualEffectView.Material,
    blendingMode: NSVisualEffectView.BlendingMode
  ) {
    self.material = material
    self.blendingMode = blendingMode
  }
  
  public func makeNSView(context: Context) -> NSVisualEffectView {
    let view = NSVisualEffectView()
    view.material = material
    view.blendingMode = blendingMode
    view.state = .active
    return view
  }
  
  public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    nsView.material = material
    nsView.blendingMode = blendingMode
  }
}

#Preview {
  BlurView(material: .hudWindow, blendingMode: .withinWindow)
}
#endif
