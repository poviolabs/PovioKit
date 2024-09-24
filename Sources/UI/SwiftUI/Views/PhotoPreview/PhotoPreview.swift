//
//  PhotoPreview.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 12/08/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if os(iOS)
import SwiftUI

@available(iOS 15.0, *)
public struct PhotoPreview: View {
  let items: [Item]
  let configuration: Configuration
  @Binding var presented: Bool
  @State var currentIndex = 0
  @State var offset: CGFloat = 0
  @State var verticalOffset: CGFloat = 0
  @State var imageViewDragEnabled: Bool = false
  @State var imageViewLastOffset: CGFloat = 0
  @State var dragDirection: Direction = .none
  @State var dragVelocity: CGFloat = 0
  @State var shouldSwitchDragDirection: Bool = true
  @State var backgroundOpacity: CGFloat = 1
  @State var initialDragOffset: CGFloat = .zero
  
  public init(
    items: [Item],
    configuration: Configuration,
    presented: Binding<Bool>
  ) {
    self.items = items
    self.configuration = configuration
    _presented = presented
  }
  
  public var body: some View {
    scrollView
      .ignoresSafeArea()
      .overlay {
        if configuration.showDismissButton {
          dismissView
            .opacity(hideDismissButton ? 0 : 1)
        }
      }
      .background(
        configuration
          .backgroundColor
          .opacity(backgroundOpacity)
      )
  }
}

// MARK: - ViewBuilders
@available(iOS 15.0, *)
extension PhotoPreview {
  var scrollView: some View {
    GeometryReader { geometry in
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 0) {
          ForEach(0..<items.count, id: \.self) { index in
            ItemView(
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
        .drawingGroup()
      }
      .content
      .offset(x: contentOffset(for: geometry))
      .simultaneousGesture(dragGesture(with: geometry))
      .background {
        Color.clear
          .contentShape(Rectangle())
          .simultaneousGesture(dragGesture(with: geometry))
      }
    }
  }
  
  var dismissView: some View {
    VStack {
      Button {
        presented.toggle()
      } label: {
        Image(systemName: "xmark.circle.fill")
          .resizable()
          .foregroundColor(.white)
          .frame(width: 30, height: 30)
          .padding(.trailing, 24)
      }
      .shadow(radius: 2)
      Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .trailing)
  }
}

// MARK: - Helpers
@available(iOS 15.0, *)
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
    if initialDragOffset == .zero && imageViewLastOffset == .zero {
      // we store the initial offset to avoid views from jumping
      initialDragOffset = value.translation.width
    }
    offset = value.translation.width - imageViewLastOffset - initialDragOffset
    if imageViewLastOffset == .zero {
      dragVelocity = value.predictedEndLocation.x - value.location.x
    }
  }
  
  func horizontalDragEnded(with pageWidth: CGFloat) {
    dragDirection = .none
    initialDragOffset = .zero
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
    updateBackgroundOpacity()
  }
  
  func verticalDragEnded() {
    shouldSwitchDragDirection = true
    dragDirection = .none
    if dragVelocity > configuration.velocityThreshold.height || verticalOffset > configuration.offsetThreshold {
      presented.toggle()
      return
    }
    withAnimation {
      verticalOffset = 0
      backgroundOpacity = 1
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
  
  func updateBackgroundOpacity() {
    let height = UIScreen.main.bounds.height / 2
    let progress = verticalOffset / height
    withAnimation {
      backgroundOpacity = 1.0 - progress
    }
  }
  
  var hideDismissButton: Bool {
    backgroundOpacity < 1.0
  }
}

// MARK: - Gestures
@available(iOS 15.0, *)
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
