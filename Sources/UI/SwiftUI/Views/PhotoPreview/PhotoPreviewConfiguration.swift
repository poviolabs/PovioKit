//
//  PhotoPreviewConfiguration.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 09/09/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

public struct PhotoPreviewConfiguration {
  let backgroundColor: Color
  let showDismissButton: Bool
  let velocityThreshold: CGSize
  let offsetThreshold: CGFloat
}

public extension PhotoPreviewConfiguration {
  static var defaultConfiguration: PhotoPreviewConfiguration {
    .init(
      backgroundColor: .black,
      showDismissButton: true,
      velocityThreshold: .init(width: 200, height: 1000),
      offsetThreshold: 80
    )
  }
}
