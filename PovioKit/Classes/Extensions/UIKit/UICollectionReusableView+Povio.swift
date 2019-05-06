//
//  UICollectionReusableView+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import UIKit

public extension UICollectionReusableView {
  /// Returns cell's reuse identifier
  static var identifier: String {
    return String(describing: self)
  }
}
