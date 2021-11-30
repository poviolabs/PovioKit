//
//  UITableViewHeaderFooterView+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2021 Povio Inc. All rights reserved.
//

import UIKit

public extension UITableViewHeaderFooterView {
  /// Returns cell's reuse identifier
  static var identifier: String {
    String(describing: self)
  }
}
