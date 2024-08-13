//
//  PhotoPreview.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 12/08/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if os(iOS)
import SwiftUI

@available(iOS 14.0, *)
public struct PhotoPreview: View {
  let items: [PhotoPreviewItem]
  @State var currentIndex = 0
  @State var offset: CGFloat = 0
  @State var imageViewDragEnabled: Bool = false
  @State var imageViewLastOffset: CGFloat = 0
  
  public init(items: [PhotoPreviewItem]) {
    self.items = items
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 0) {
          ForEach(0..<items.count, id: \.self) { index in
            PhotoPreviewItemView(
              dragEnabled: $imageViewDragEnabled,
              currentIndex: $currentIndex,
              item: items[index],
              myIndex: index
            ) { newValue in
              imageViewLastOffset = newValue
            } onDragEnded: {
              dragEnded(with: geometry.size.width)
            }
            .frame(width: geometry.size.width)
            .clipped()
            .id(index)
          }
        }
      }
      .content
      .offset(x: contentOffset(for: geometry))
      .simultaneousGesture(dragGesture(with: geometry))
    }
  }
}

// MARK: - Helpers
@available(iOS 14.0, *)
extension PhotoPreview {
  func contentOffset(for geometry: GeometryProxy) -> CGFloat {
    -CGFloat(currentIndex) * geometry.size.width + offset
  }
  
  func resetOffset() {
    offset = 0
  }
  
  func dragEnded(with pageWidth: CGFloat) {
    let threshold = pageWidth / 3
    if offset < -threshold && currentIndex < items.count - 1 {
      withAnimation {
        currentIndex += 1
        resetOffset()
      }
    } else if offset > threshold && currentIndex > 0 {
      withAnimation {
        currentIndex -= 1
        resetOffset()
      }
    } else {
      withAnimation {
        resetOffset()
      }
    }
  }
}

// MARK: - Gestures
@available(iOS 14.0, *)
extension PhotoPreview {
  func dragGesture(with geometry: GeometryProxy) -> some Gesture {
    DragGesture()
      .onChanged { value in
        guard !imageViewDragEnabled else { return }
        offset = value.translation.width - imageViewLastOffset
      }
      .onEnded { value in
        if imageViewLastOffset != 0 {
          imageViewDragEnabled = true
        }
        imageViewLastOffset = 0
        dragEnded(with: geometry.size.width)
      }
  }
}
#endif
