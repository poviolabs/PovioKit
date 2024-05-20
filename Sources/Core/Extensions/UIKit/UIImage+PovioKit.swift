//
//  UIImage+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UIImage {
  /// Initializes a symbol image on iOS 13 or image from the given `bundle` for given `name`
  convenience init?(systemNameOr name: String, in bundle: Bundle? = Bundle.main, compatibleWith traitCollection: UITraitCollection? = nil) {
    self.init(systemName: name, compatibleWith: traitCollection)
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
  
  /// Returns existing image clipped to a circle
  var clipToCircle: UIImage {
    let layer = CALayer()
    layer.frame = .init(origin: .zero, size: size)
    layer.contents = cgImage
    layer.masksToBounds = true
    
    layer.cornerRadius = size.width / 2
    
    UIGraphicsBeginImageContext(size)
    guard let context = UIGraphicsGetCurrentContext() else { return self }
    layer.render(in: context)
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return roundedImage ?? self
  }
}

#endif
