//
//  PhotoPreview+Configuration.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 09/09/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, *)
public extension PhotoPreview {
  /// Configuration for customizing `PhotoPreview`.
  struct Configuration {
    /// The preview's background color.
    public var backgroundColor: Color
    /// Whether to display the dismiss button.
    public var showDismissButton: Bool
    /// The velocity threshold for dismissing the preview.
    public var velocityThreshold: CGSize
    /// The offset threshold for dismissing the preview.
    public var offsetThreshold: CGFloat
    
    /// Creates a new configuration.
    /// - Parameters:
    ///   - backgroundColor: The background color.
    ///   - showDismissButton: A flag for showing the dismiss button.
    ///   - velocityThreshold: The gesture velocity threshold.
    ///   - offsetThreshold: The gesture offset threshold.
    public init(
      backgroundColor: Color,
      showDismissButton: Bool,
      velocityThreshold: CGSize,
      offsetThreshold: CGFloat
    ) {
      self.backgroundColor = backgroundColor
      self.showDismissButton = showDismissButton
      self.velocityThreshold = velocityThreshold
      self.offsetThreshold = offsetThreshold
    }
  }
}

@available(iOS 16.0, *)
public extension PhotoPreview.Configuration {
  /// Default configuration for `PhotoPreview`.
  static var `default`: Self {
    .init(
      backgroundColor: .black,
      showDismissButton: true,
      velocityThreshold: .init(width: 200, height: 1000),
      offsetThreshold: 80
    )
  }
}
