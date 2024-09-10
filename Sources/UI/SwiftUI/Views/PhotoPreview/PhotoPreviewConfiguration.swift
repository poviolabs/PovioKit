//
//  PhotoPreviewConfiguration.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 09/09/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

public struct PhotoPreviewConfiguration {
  public var backgroundColor: Color
  public var showDismissButton: Bool
  public var velocityThreshold: CGSize
  public var offsetThreshold: CGFloat
  
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

public extension PhotoPreviewConfiguration {
  static var `default`: PhotoPreviewConfiguration {
    .init(
      backgroundColor: .black,
      showDismissButton: true,
      velocityThreshold: .init(width: 200, height: 1000),
      offsetThreshold: 80
    )
  }
}
