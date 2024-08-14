//
//  PhotoPreviewModifier.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 14/08/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
struct PhotoPreviewModifier: ViewModifier {
  public typealias VoidHandler = () -> Swift.Void
  @Binding var presented: Bool
  let items: [PhotoPreviewItem]
  let onDismiss: VoidHandler?
  
  public func body(content: Content) -> some View {
    content
      .fullScreenCover(isPresented: $presented) {
        PhotoPreview(items: items) {
          presented.toggle()
          onDismiss?()
        }
        .ignoresSafeArea()
      }
  }
}

@available(iOS 14.0, *)
public extension View {
  func photoPreview(
    present: Binding<Bool>,
    items: [PhotoPreviewItem],
    onDismiss: (() -> Swift.Void)? = nil
  ) -> some View {
    modifier(PhotoPreviewModifier(
      presented: present,
      items: items, 
      onDismiss: onDismiss
    ))
  }
}
