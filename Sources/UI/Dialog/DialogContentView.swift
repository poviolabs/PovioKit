//
//  DialogContentView.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 4/19/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import UIKit

/// UIView that holds user-defined custom UI
/// In subclass, use ``content`` UIView to addSubview
///
/// ```swift
/// //Example:
/// content.addSubview(button)
/// ```
open class DialogContentView: UIView {
  
  /// Background view that will hold tap gesture for dismissing Dialog
  private let backgroundView = UIView()
  
  /// UIScrollView that will be responsible for scrollable content (if content can not fit the screen)
  private let scrollView = UIScrollView()
  
  /// Main content view. Use it to add subviews
  public let content = UIView()
  
  public init() {
    super.init(frame: .zero)
    setupSubviews()
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

internal extension DialogContentView {
  
  /// Set NSLayoutConstraint based on the provided ``DialogPosition``
  /// - Parameter position: ``DialogPosition``
  func setPosition(_ position: DialogPosition) {
    switch position {
    case .bottom:
      setBottomStyleConstraints()
    case .top:
      setTopStyleConstraints()
    case .center:
      setCenterStyleConstraints()
    }
  }
  
  /// Add tap to dismiss gesture on background view
  func addDismissGesture(_ gesture: UITapGestureRecognizer) {
    backgroundView.addGestureRecognizer(gesture)
  }
}

private extension DialogContentView {
  func setupSubviews() {
    setupBackgroundView()
    setupScrollView()
    setupContent()
  }
  
  func setupBackgroundView() {
    addSubview(backgroundView)
    backgroundView.backgroundColor = .clear
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
      backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
  }
  
  func setupScrollView() {
    addSubview(scrollView)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func setupContent() {
    scrollView.addSubview(content)
    content.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      content.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      content.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      content.topAnchor.constraint(equalTo: scrollView.topAnchor),
      content.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      content.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.widthAnchor),
      content.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
    ])
  }
}

// MARK: - ScrollView Constraints
private extension DialogContentView {
  func setBottomStyleConstraints() {
    let bottomAnchor = scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    bottomAnchor.priority = .required
    let topAnchor = scrollView.topAnchor.constraint(equalTo: self.topAnchor)
    topAnchor.priority = .init(rawValue: 1)
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      bottomAnchor, topAnchor
    ])
  }
  
  func setTopStyleConstraints() {
    let bottomAnchor = scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    bottomAnchor.priority = .init(rawValue: 1)
    let topAnchor = scrollView.topAnchor.constraint(equalTo: self.topAnchor)
    topAnchor.priority = .required
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      topAnchor, bottomAnchor
    ])
  }
  
  func setCenterStyleConstraints() {
    let topAnchor = scrollView.topAnchor.constraint(equalTo: self.topAnchor)
    topAnchor.priority = .init(rawValue: 1)
    let bottomAnchor = scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    bottomAnchor.priority = .init(rawValue: 1)
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      scrollView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      topAnchor, bottomAnchor
    ])
  }
}
