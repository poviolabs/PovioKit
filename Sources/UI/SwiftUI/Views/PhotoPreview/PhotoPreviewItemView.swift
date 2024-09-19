//
//  PhotoPreviewItemView.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 12/08/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if canImport(Kingfisher)
import Kingfisher
#endif
import SwiftUI

@available(iOS 15.0, *)
struct PhotoPreviewItemView: View {
  typealias VoidHandler = () -> Swift.Void
  typealias DragHandler = (CGFloat) -> Swift.Void
  
  @Binding var dragEnabled: Bool
  @Binding var currentIndex: Int
  @Binding var verticalOffset: CGFloat
  @State var scale: CGFloat = 1.0
  @State var lastScaleValue: CGFloat = 1.0
  @State var offset = CGSize.zero
  @State var lastOffset = CGSize.zero
  let item: PhotoPreviewItem
  let myIndex: Int
  let onDragChanged: DragHandler
  let onDragEnded: VoidHandler
  let dragHorizontalPadding: CGFloat = 24
  let screenSize: CGSize = UIScreen.main.bounds.size
  
  var body: some View {
    imageView
      .scaleEffect(scale)
      .offset(offset)
      .offset(y: verticalOffset)
      .gesture(magnificationGesture)
      .simultaneousGesture(dragEnabled ? dragGesture : nil)
      .onTapGesture(count: 2) {
        handleDoubleTap()
      }
      .onChange(of: scale) { value in
        dragEnabled = value != 1.0
      }
      .onChange(of: dragEnabled) { value in
        guard value, offset != .zero else {
          return
        }
        endDrag(animated: true)
      }
      .onChange(of: currentIndex) { index in
        if index != myIndex {
          withAnimation {
            resetScaleAndPosition()
          }
        }
      }
  }
}

// MARK: - Views
@available(iOS 15.0, *)
extension PhotoPreviewItemView {
  var imageView: some View {
    Group {
      if let image = item.image {
        image
          .resizable()
          .scaledToFit()
          .aspectRatio(contentMode: .fit)
      } else {
        remoteImageView
      }
    }
  }
  
  var remoteImageView: some View {
    #if canImport(Kingfisher)
    KFImage(item.url)
      .resizable()
      .placeholder {
        (item.placeholder ?? Image(uiImage: UIImage()))
          .resizable()
      }
      .scaledToFit()
    #else
    URLImageView(from: item.url, placeholder: item.placeholder)
    #endif
  }
}

// MARK: - Helper methods
@available(iOS 15.0, *)
extension PhotoPreviewItemView {
  func endDrag(animated: Bool = true) {
    let imageWidth = screenSize.width * scale
    let imageHeight = screenSize.height * scale
    let maxXOffset = max((imageWidth - screenSize.width) / 2, 0)
    let maxYOffset = max((imageHeight - screenSize.height) / 2, 0)
    
    var finalOffset = offset
    
    // Snap back horizontally
    if offset.width > maxXOffset {
      finalOffset.width = maxXOffset
    } else if offset.width < -maxXOffset {
      finalOffset.width = -maxXOffset
    }
    
    // Snap back vertically
    if offset.height > maxYOffset {
      finalOffset.height = maxYOffset
    } else if offset.height < -maxYOffset {
      finalOffset.height = -maxYOffset
    }
    
    guard animated else {
      setOffset(finalOffset)
      return
    }
    withAnimation {
      setOffset(finalOffset)
    }
  }
  
  func handleDoubleTap() {
    withAnimation {
      if scale == 1.0 {
        scale = 2.0
      } else {
        resetScaleAndPosition()
      }
    }
  }
  
  func setOffset(_ newOffset: CGSize) {
    offset = newOffset
    lastOffset = newOffset
  }
  
  func resetScaleAndPosition() {
    scale = 1.0
    offset = .zero
    lastOffset = .zero
  }
}

// MARK: - Gestures
@available(iOS 15.0, *)
extension PhotoPreviewItemView {
  var magnificationGesture: some Gesture {
    MagnificationGesture()
      .onChanged { value in
        let delta = value / lastScaleValue
        lastScaleValue = value
        scale = min(scale * delta, 4.0)
      }
      .onEnded { _ in
        lastScaleValue = 1.0
        if scale < 1.0 {
          withAnimation {
            resetScaleAndPosition()
          }
        }
      }
  }
  
  var dragGesture: some Gesture {
    DragGesture()
      .onChanged { value in
        guard scale > 1.0 else {
          dragEnabled = false
          return
        }
        let imageWidth = screenSize.width * scale
        let maxXOffset = max((imageWidth - screenSize.width) / 2, 0) + dragHorizontalPadding
        let newXOffset = lastOffset.width + value.translation.width
        if offset.width >= maxXOffset || offset.width <= -maxXOffset {
          onDragChanged(value.translation.width)
          dragEnabled = false
          return
        }
        offset = CGSize(
          width: newXOffset,
          height: lastOffset.height + value.translation.height
        )
      }
      .onEnded { value in
        guard scale > 1.0 else { return }
        // Vertical limit handling
        let imageHeight = screenSize.height * scale
        let maxYOffset = max((imageHeight - screenSize.height) / 2, 0) + dragHorizontalPadding
        
        // Animate to the middle if out of bounds
        if offset.height >= maxYOffset || offset.height <= -maxYOffset {
          withAnimation {
            offset.height = 0
          }
        }
        endDrag()
      }
  }
}
