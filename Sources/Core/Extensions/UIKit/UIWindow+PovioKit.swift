//
//  UIWindow+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 5/1/2023.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import UIKit

extension UIWindow {
  /// Returns `UIEdgeInsets` for the possible (top/bottom) safe areas
  static var safeAreaInsets: UIEdgeInsets {
    UIApplication.shared.windows
      .first { $0.isKeyWindow }
      .map { $0.rootViewController?.view?.safeAreaInsets ?? .zero } ?? .zero
  }
}
