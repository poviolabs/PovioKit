//
//  UITableViewHeaderFooterView+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import UIKit

public extension UITableViewHeaderFooterView {
  /// Returns cell's reuse identifier
  static var identifier: String {
    String(describing: self)
  }
}
