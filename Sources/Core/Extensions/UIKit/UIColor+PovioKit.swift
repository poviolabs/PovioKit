//
//  UIColor+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import UIKit

public extension UIColor {
  convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
    self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: alpha)
  }
}
