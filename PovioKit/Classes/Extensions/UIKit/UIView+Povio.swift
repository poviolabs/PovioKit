//
//  UIView+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import UIKit

// MARK: - Shadow and border
public extension UIView {
  func dropShadow(path: UIBezierPath?, shadowColor: UIColor, radius: CGFloat, opacity: Float, offset: CGSize) {
    layer.shadowPath = path?.cgPath
    layer.shadowColor = shadowColor.cgColor
    layer.shadowOffset = offset
    layer.shadowOpacity = opacity
    layer.shadowRadius = radius
  }
  
  func applyBorder(color: UIColor, width: CGFloat) {
    layer.borderColor = color.cgColor
    layer.borderWidth = width
  }
}

// MARK: - AutoLayout
public extension UIView {
  func autolayoutView() -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    return self
  }
  
  class func autolayoutView() -> Self {
    let instance = self.init()
    instance.translatesAutoresizingMaskIntoConstraints = false
    return instance
  }
}

// MARK: - Animations
public extension UIView {
  struct AnimationKey {
    static let rotation = "rotationAnimationKey"
    static let shadowOpacity = "shadowOpacityKey"
  }
  
  func rotate() {
    if layer.animation(forKey: UIView.AnimationKey.rotation) == nil {
      let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
      rotationAnimation.fromValue = 0.0
      rotationAnimation.toValue = Float.pi * 2.0
      rotationAnimation.duration = 1.25
      rotationAnimation.repeatCount = Float.infinity
      layer.add(rotationAnimation, forKey: UIView.AnimationKey.rotation)
    }
  }
  
  func stopRotating() {
    if layer.animation(forKey: UIView.AnimationKey.rotation) != nil {
      layer.removeAnimation(forKey: UIView.AnimationKey.rotation)
    }
  }
}
