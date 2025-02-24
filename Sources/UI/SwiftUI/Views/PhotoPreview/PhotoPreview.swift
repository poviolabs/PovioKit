//
//  PhotoPreview.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 12/08/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if os(iOS)
import SwiftUI

@available(iOS 16.0, *)
public struct PhotoPreview: View {
  let items: [Item]
  let configuration: Configuration
  @Binding var presented: Bool
  @State var currentIndex: Int = 0
  @State var verticalOffset: CGFloat = 0
  @State var imageViewDragEnabled: Bool = false
  @State var dragDirection: Direction = .none
  @State var dragVelocity: CGFloat = 0
  @State var shouldSwitchDragDirection: Bool = true
  @State var backgroundOpacity: CGFloat = 1
  
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
@available(iOS 16.0, *)
extension PhotoPreview {
  var scrollView: some View {
    GeometryReader { geometry in
      TabView(selection: $currentIndex) {
        ForEach(0..<items.count, id: \.self) { index in
          ItemView(
            dragEnabled: $imageViewDragEnabled,
            currentIndex: $currentIndex,
            verticalOffset: $verticalOffset,
            item: items[index],
            myIndex: index
          )
          .frame(width: geometry.size.width)
          .id(index)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .simultaneousGesture(dragGesture(with: geometry))
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
@available(iOS 16.0, *)
extension PhotoPreview {
  enum Direction {
    case vertical
    case horizontal
    case none
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
    guard dragDirection == .vertical else { return }
    verticalDragEnded()
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
@available(iOS 16.0, *)
extension PhotoPreview {
  func dragGesture(with geometry: GeometryProxy) -> some Gesture {
    DragGesture()
      .onChanged { value in
        guard !imageViewDragEnabled else { return }
        if verticalOffset > 30 {
          shouldSwitchDragDirection = false
        }
        if dragDirection == .none || shouldSwitchDragDirection {
          dragDirection = abs(value.translation.width) > abs(value.translation.height) ? .horizontal : .vertical
        }
        if dragDirection == .vertical {
          verticalDragChanged(with: value)
        }
      }
      .onEnded { _ in
        dragEnded(with: geometry.size.width)
      }
  }
}
#endif
