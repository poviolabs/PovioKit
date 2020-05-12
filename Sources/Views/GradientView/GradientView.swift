//
//  GradientView.swift
//  PovioKit
//
//  Created by Domagoj Kulundzic on 01/05/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit

public class GradientView: UIView {
  public var isShowingGradient: Bool = true {
    didSet {
      gradientLayer.isHidden = !isShowingGradient
    }
  }
  
  let gradientLayer: CAGradientLayer = CAGradientLayer()
  
  public init(colors: [UIColor]) {
    gradientLayer.colors = colors.map { $0.cgColor }
    super.init(frame: .zero)
    setupViews()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer.frame = bounds
  }
}

public extension GradientView {
  func setGradientColors(_ colors: [UIColor]?, locations: [NSNumber]? = nil, animated: Bool, animationDuration: Double = 0.3) {
    guard let colors = colors else {
      gradientLayer.colors = nil
      gradientLayer.locations = nil
      return
    }
    
    guard animated else {
      gradientLayer.colors = colors.map { $0.cgColor }
      gradientLayer.locations = locations
      return
    }
    
    let gradientColorsChangeAnimation = CABasicAnimation(keyPath: "colors")
    gradientColorsChangeAnimation.duration = animationDuration
    gradientColorsChangeAnimation.toValue = colors.map { $0.cgColor }
    gradientColorsChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
    gradientColorsChangeAnimation.isRemovedOnCompletion = false
    gradientLayer.add(gradientColorsChangeAnimation, forKey: "colorChange")
    
    let gradientLocationsChangeAnimation = CABasicAnimation(keyPath: "locations")
    gradientLocationsChangeAnimation.duration = animationDuration
    gradientLocationsChangeAnimation.toValue = locations
    gradientLocationsChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
    gradientLocationsChangeAnimation.isRemovedOnCompletion = false
    gradientLayer.add(gradientLocationsChangeAnimation, forKey: "locationsChange")
  }
  
  func setLocations(locations: [NSNumber]) {
    gradientLayer.locations = locations
  }
  
  func setGradient(startPoint: CGPoint, endPoint: CGPoint) {
    gradientLayer.startPoint = startPoint
    gradientLayer.endPoint = endPoint
  }
}

private extension GradientView {
  func setupViews() {
    layer.insertSublayer(gradientLayer, at: 0)
  }
}
