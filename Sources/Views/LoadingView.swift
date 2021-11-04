//
//  LoadingView.swift
//  PovioKit
//
//  Created by Toni Kocjan on 04/11/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import UIKit

/// Adapt any view into a loading view.
open class LoadingView<V: UIView>: UIControl {
  public let view: V
  public let activityIndicator: UIActivityIndicatorView
  let animations: Animations?
  
  public init(
    adapt view: V,
    activityIndicatorStyle style: UIActivityIndicatorView.Style = .white,
    animations: Animations?
  ) {
    self.view = view
    self.activityIndicator = .init(style: style)
    self.animations = animations
    super.init(frame: .zero)
    self.view.translatesAutoresizingMaskIntoConstraints = false
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    addSubview(self.view)
    NSLayoutConstraint.activate([
      view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      view.topAnchor.constraint(equalTo: self.topAnchor),
      view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
    addSubview(self.activityIndicator)
    NSLayoutConstraint.activate([
      view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      view.centerXAnchor.constraint(equalTo: self.centerXAnchor),
    ])
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func startLoading() {
    guard !activityIndicator.isAnimating else { return }
    
    activityIndicator.startAnimating()
    view.isUserInteractionEnabled = false
    
    guard let animation = animations?.startLoadingAnimation else { return }
    UIView.animate(withDuration: 0.3) {
      animation(self.view, self.activityIndicator)
    }
  }
  
  public func stopLoading() {
    guard activityIndicator.isAnimating else { return }
    
    activityIndicator.stopAnimating()
    view.isUserInteractionEnabled = true
    
    guard let animation = animations?.stopLoadingAnimation else { return }
    UIView.animate(withDuration: 0.3) {
      animation(self.view, self.activityIndicator)
    }
  }
}

public extension LoadingView {
  typealias Animation = (_ view: V, _ activityIndicator: UIActivityIndicatorView) -> Void
  
  struct Animations {
    let startLoadingAnimation: Animation
    let stopLoadingAnimation: Animation
    
    public init(
      startLoadingAnimation: @escaping Animation,
      stopLoadingAnimation: @escaping Animation
    ) {
      self.startLoadingAnimation = startLoadingAnimation
      self.stopLoadingAnimation = stopLoadingAnimation
    }
  }
}

open class LoadingButton<B: UIButton>: LoadingView<B> {
  public override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
    view.addTarget(target, action: action, for: controlEvents)
  }
  
  public func setTitle(_ title: String, for state: UIControl.State) {
    view.setTitle(title, for: state)
  }
  
  public func setImage(_ image: UIImage?, for state: UIControl.State) {
    view.setImage(image, for: state)
  }
}
