//
//  UIImage+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2021 Povio Inc. All rights reserved.
//

import UIKit

public extension UIImage {
  /// Initializes a symbol image on iOS 13 or image from the given `bundle` for given `name`
  convenience init?(systemNameOr name: String, in bundle: Bundle? = Bundle.main, compatibleWith traitCollection: UITraitCollection? = nil) {
    if #available(iOS 13, *) {
      self.init(systemName: name, compatibleWith: traitCollection)
    } else {
      self.init(named: name, in: bundle, compatibleWith: traitCollection)
    }
  }
  
  /// Tints image with given color
  func tinted(with color: UIColor) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    let context = UIGraphicsGetCurrentContext()
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    draw(in: rect, blendMode: .normal, alpha: 1)
    
    context?.setBlendMode(.sourceIn)
    context?.setFillColor(color.cgColor)
    context?.fill(rect)
    
    let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return tintedImage ?? self
  }
  
  /// Generates new *UIImage* tinted with given color and size
  static func with(color: UIColor, size: CGSize) -> UIImage {
    UIGraphicsBeginImageContext(size)
    let path = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size))
    color.setFill()
    path.fill()
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image ?? UIImage()
  }
  
  static func named(_ name: String) -> UIImage? {
    .init(named: name)
  }
}
