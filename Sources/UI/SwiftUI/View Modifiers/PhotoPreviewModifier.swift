//
//  PhotoPreviewModifier.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 14/08/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, *)
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
        .presentationBackgroundIfAvailable(.black.opacity(0.01))
      }
  }
}

@available(iOS 16.0, *)
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

@available(iOS 16.0, *)
extension PhotoPreviewModifier {
  struct PresentationBackgroundModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
      if #available(iOS 16.4, *) {
        content
          .presentationBackground(color)
      } else {
        content
      }
    }
  }
}

@available(iOS 16.0, *)
extension View {
  func presentationBackgroundIfAvailable(_ color: Color) -> some View {
    modifier(PhotoPreviewModifier.PresentationBackgroundModifier(color: color))
  }
}
