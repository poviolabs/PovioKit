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
  public typealias VoidHandler = () -> Swift.Void
  let items: [PhotoPreviewItem]
  let configuration: PhotoPreviewConfiguration
  let dismiss: VoidHandler
  @State var currentIndex = 0
  @State var offset: CGFloat = 0
  @State var verticalOffset: CGFloat = 0
  @State var imageViewDragEnabled: Bool = false
  @State var imageViewLastOffset: CGFloat = 0
  @State var dragDirection: Direction = .none
  @State var dragVelocity: CGFloat = 0
  @State var shouldSwitchDragDirection: Bool = true
  
  public init(
    items: [PhotoPreviewItem],
    configuration: PhotoPreviewConfiguration,
    dismiss: @escaping VoidHandler
  ) {
    self.items = items
    self.configuration = configuration
    self.dismiss = dismiss
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 0) {
          ForEach(0..<items.count, id: \.self) { index in
            PhotoPreviewItemView(
              dragEnabled: $imageViewDragEnabled,
              currentIndex: $currentIndex,
              verticalOffset: $verticalOffset,
              item: items[index],
              myIndex: index
            ) { newValue in
              imageViewLastOffset = newValue
            } onDragEnded: {
              horizontalDragEnded(with: geometry.size.width)
            }
            .frame(width: geometry.size.width)
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
  enum Direction {
    case vertical
    case horizontal
    case none
  }
  
  func contentOffset(for geometry: GeometryProxy) -> CGFloat {
    -CGFloat(currentIndex) * geometry.size.width + offset
  }
  
  func resetOffset() {
    offset = 0
  }
  
  func horizontalDragChanged(with value: DragGesture.Value) {
    offset = value.translation.width - imageViewLastOffset
    if imageViewLastOffset == .zero {
      dragVelocity = value.predictedEndLocation.x - value.location.x
    }
  }
  
  func horizontalDragEnded(with pageWidth: CGFloat) {
    dragDirection = .none
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
    } else if !imageViewDragEnabled, abs(dragVelocity) > configuration.velocityThreshold.width {
      withAnimation {
        let dragDirection = dragVelocity > .zero ? -1 : 1
        var updatedIndex = currentIndex + dragDirection
        // Ensure the new index is within bounds
        updatedIndex = min(max(updatedIndex, 0), items.count - 1)
        currentIndex = updatedIndex
        resetOffset()
      }
    } else {
      withAnimation {
        resetOffset()
      }
    }
  }
  
  func verticalDragChanged(with value: DragGesture.Value) {
    dragDirection = .vertical
    verticalOffset = value.translation.height
    dragVelocity = value.predictedEndLocation.y - value.location.y
  }
  
  func verticalDragEnded() {
    shouldSwitchDragDirection = true
    dragDirection = .none
    if dragVelocity > configuration.velocityThreshold.height || verticalOffset > configuration.offsetThreshold {
      dismiss()
      return
    }
    withAnimation {
      verticalOffset = 0
    }
  }
  
  func dragEnded(with pageWidth: CGFloat) {
    if imageViewLastOffset != 0 {
      imageViewDragEnabled = true
    }
    imageViewLastOffset = 0
    
    if dragDirection == .horizontal {
      horizontalDragEnded(with: pageWidth)
    } else {
      verticalDragEnded()
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
        if offset > 30 || verticalOffset > 30 {
          shouldSwitchDragDirection = false
        }
        if dragDirection == .none || shouldSwitchDragDirection {
          dragDirection = abs(value.translation.width) > abs(value.translation.height) ? .horizontal : .vertical
        }
        if dragDirection == .horizontal {
          horizontalDragChanged(with: value)
        } else if imageViewLastOffset == .zero, offset == 0 {
          verticalDragChanged(with: value)
        }
      }
      .onEnded { _ in
        dragEnded(with: geometry.size.width)
      }
  }
}
#endif
