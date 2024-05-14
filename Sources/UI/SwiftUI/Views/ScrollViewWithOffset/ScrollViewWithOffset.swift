//
//  ScrollViewWithOffset.swift
//  PovioKit
//
//  Created by Borut Tomazin on 10/02/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

/// This scroll view wraps a native `ScrollView` and tracks its
/// scroll offset as it scrolls.
///
/// You can use the `onScroll` initializer parameter to provide
/// a function that will be called whenever the view scrolls.
///
/// Source: https://github.com/danielsaidi/ScrollKit/blob/main/Sources/ScrollKit/ScrollViewWithOffset.swift
@available(iOS 15.0, *)
public struct ScrollViewWithOffset<Content: View>: View {
  /**
   Create a scroll view with offset tracking.
   
   - Parameters:
   - axes: The scroll axes to use, by default `.vertical`.
   - showsIndicators: Whether or not to show scroll indicators, by default `true`.
   - onScroll: An action that will be called whenever the scroll offset changes, by default `nil`.
   - content: The scroll view content.
   */
  public init(
    _ axes: Axis.Set = .vertical,
    showsIndicators: Bool = true,
    onScroll: ScrollAction? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.axes = axes
    self.showsIndicators = showsIndicators
    self.onScroll = onScroll ?? { _ in }
    self.content = content
  }
  
  private let axes: Axis.Set
  private let showsIndicators: Bool
  private let onScroll: ScrollAction
  private let content: () -> Content
  
  public typealias ScrollAction = (_ offset: CGPoint) -> Void
  
  public var body: some View {
    ScrollView(axes, showsIndicators: showsIndicators) {
      ZStack(alignment: .top) {
        ScrollViewOffsetTracker()
        content()
      }
    }.withOffsetTracking(action: onScroll)
  }
}

private struct ScrollViewOffsetTracker: View {
  var body: some View {
    GeometryReader { geo in
      Color.clear
        .preference(
          key: ScrollOffsetPreferenceKey.self,
          value: geo.frame(in: .named(ScrollOffsetNamespace.namespace)).origin
        )
    }
    .frame(height: 0)
  }
}

private extension ScrollView {
  func withOffsetTracking(
    action: @escaping (_ offset: CGPoint) -> Void
  ) -> some View {
    self.coordinateSpace(name: ScrollOffsetNamespace.namespace)
      .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: action)
  }
}

private enum ScrollOffsetNamespace {
  static let namespace = "scrollView"
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGPoint = .zero
  static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { /* no impl */ }
}
