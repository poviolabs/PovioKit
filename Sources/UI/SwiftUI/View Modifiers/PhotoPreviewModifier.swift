//
//  PhotoPreviewModifier.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 14/08/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

@available(iOS 15.0, *)
struct PhotoPreviewModifier: ViewModifier {
  @Binding var presented: Bool
  let items: [PhotoPreview.Item]
  let configuration: PhotoPreview.Configuration
  
  public func body(content: Content) -> some View {
    content
      .fullScreenCover(isPresented: $presented) {
        PhotoPreview(
          items: items,
          configuration: configuration,
          presented: $presented
        )
      }
  }
}

@available(iOS 15.0, *)
public extension View {
  func photoPreview(
    present: Binding<Bool>,
    items: [PhotoPreview.Item],
    configuration: PhotoPreview.Configuration = .default
  ) -> some View {
    modifier(PhotoPreviewModifier(
      presented: present,
      items: items,
      configuration: configuration
    ))
  }
}
