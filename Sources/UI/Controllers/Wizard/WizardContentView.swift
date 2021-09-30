//
//  File.swift
//  
//
//  Created by Toni Kocjan on 29/09/2021.
//

import Foundation
import UIKit

open class WizardContentView: UIView {
  /// Layout the view per your requirements
  public let contentView = UIView()
  private(set) var isPerformingLayout = false
  
  public init() {
    super.init(frame: .zero)
    contentView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension WizardContentView {
  func transitionToView(
    _ view: UIView,
    transitionDuration duration: TimeInterval,
    animate: WizardTransitionAnimator?,
    completion: @escaping () -> Void
  ) {
    view.translatesAutoresizingMaskIntoConstraints = false
    guard let current = contentView.subviews.first else {
      firstTransition(view, transitionDuration: duration, completion: completion)
      return
    }
    nextTransition(
      current: current,
      next: view,
      transitionDuration: duration,
      animate: animate,
      completion: completion)
  }
  
  private func firstTransition(
    _ view: UIView,
    transitionDuration duration: TimeInterval,
    completion: @escaping () -> Void
  ) {
    contentView.addSubview(view)
    NSLayoutConstraint.activate([
      view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      view.topAnchor.constraint(equalTo: contentView.topAnchor),
      view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
    contentView.layoutIfNeeded()
    
    view.alpha = 0
    UIView.animate(
      withDuration: duration,
      animations: {
        view.alpha = 1
      },
      completion: { _ in
        completion()
      }
    )
  }
  
  private func nextTransition(
    current: UIView,
    next: UIView,
    transitionDuration duration: TimeInterval,
    animate: WizardTransitionAnimator?,
    completion: @escaping () -> Void
  ) {
    contentView.addSubview(next)
    NSLayoutConstraint.activate([
      next.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      next.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      next.topAnchor.constraint(equalTo: contentView.topAnchor),
      next.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
    contentView.layoutIfNeeded()
    current.constraints.forEach { $0.priority = .sceneSizeStayPut }
    
    if let animate = animate {
      animate(current, next)
    } else {
      current.isHidden = true
    }
    
    isPerformingLayout = true
    UIView.animate(
      withDuration: duration,
      animations: layoutIfNeeded,
      completion: { _ in
        self.isPerformingLayout = false
        current.removeFromSuperview()
        completion()
      }
    )
  }
}
