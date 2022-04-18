//
//  BottomSheetContentView.swift
//  PovioKit
//
//  Created by Toni Kocjan on 29/09/2021.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation
import UIKit

/// Main content view of the BottomSheet
///
/// When implementing BottomSheet, main component needs to add  BottomSheetContentView's ``contentView`` as a subview:
/// ```swift
/// addSubview(contentView)
/// contentView.snp.makeConstraints {
///  $0.bottom.leading.trailing.equalToSuperview()
/// }
/// ```
open class BottomSheetContentView: UIView {
  public let contentView = UIView()
  private(set) var isPerformingLayout = false
  
  public init() {
    super.init(frame: .zero)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    addHelperGestureRecognizer()
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension BottomSheetContentView {
  func transitionToView(
    _ view: UIView,
    transitionDuration duration: TimeInterval,
    animate: BottomSheet<BottomSheetContentView>.AnimatorFactory.Animator?,
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
}

// MARK: - Private Methods
private extension BottomSheetContentView {
  func firstTransition(
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
    UIView.animate(withDuration: duration, animations: {
      view.alpha = 1
    }, completion: { _ in
      completion()
    })
  }
  
  func nextTransition(
    current: UIView,
    next: UIView,
    transitionDuration duration: TimeInterval,
    animate: BottomSheet<BottomSheetContentView>.AnimatorFactory.Animator?,
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
    UIView.animate(withDuration: duration, animations: layoutIfNeeded) { _ in
      self.isPerformingLayout = false
      current.removeFromSuperview()
      completion()
    }
  }
}

// MARK: - Private Methods - Utils
private extension BottomSheetContentView {
  func addHelperGestureRecognizer() {
    contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(skipTap)))
  }
  
  @objc func skipTap() { }
}
