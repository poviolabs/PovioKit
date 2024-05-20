//
//  CGSize+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 14/05/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

public extension CGSize {
  init(size: CGFloat) {
    self.init(width: size, height: size)
  }
}

#endif
