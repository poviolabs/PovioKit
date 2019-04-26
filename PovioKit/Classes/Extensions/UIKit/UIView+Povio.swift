//
//  UIView+Povio.swift
//  PovioKit
//
//  Created by Povio on 14/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import UIKit

// MARK: - ReusableView
public protocol ReusableView {
  static var defaultReuseIdentifier: String { get }
}

extension UIView: ReusableView {
  public static var defaultReuseIdentifier: String {
    return String(describing: self)
  }
}

// MARK: - AnimationKeys
public extension UIView {
  struct AnimationKey {
    static let rotation = "rotationAnimationKey"
    static let shadowOpacity = "shadowOpacityKey"
  }
}

// MARK: - Shadow and border
public extension UIView {
  func dropShadow(path: UIBezierPath? = nil, shadowColor: UIColor = UIColor.lightGray, radius: CGFloat = 2, opacity: Float = 0.45, offset: CGSize = CGSize(width: 0, height: 0.8)) {
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
  func performTransition(duration: TimeInterval, options: UIView.AnimationOptions, animated: Bool, transition: (() -> Void)?, completion: ((Bool) -> Void)?) {
    guard let transition = transition else {
      return
    }
    guard animated else {
      transition()
      return
    }
    return UIView.transition(with: self, duration: duration, options: options, animations: transition, completion: completion)
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
