//
//  DialogContentView.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 4/19/22.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation
import UIKit

/// UIView that holds user-defined custom UI
///
/// In subclass, use ``content`` UIView to addSubview
/// ```swift
/// // Example:
/// content.addSubview(button)
/// ```
open class DialogContentView: UIView {
  /// Background view that will hold tap gesture for dismissing Dialog
  private let backgroundView = UIView()
  
  /// UIScrollView that will be responsible for scrollable content (if content can not fit the screen)
  private let scrollView = UIScrollView()
  
  private var viewModel: DialogViewModel? {
    didSet {
      viewModelUpdated()
    }
  }
  
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

public extension DialogContentView {
  /// Sets background color
  /// - Parameters:
  ///   - color: UIColor
  ///   - alpha: alpha component, default = 1.0
  func setDialogBackground(color: UIColor, alpha: CGFloat = 1.0) {
    backgroundView.backgroundColor = color.withAlphaComponent(alpha)
  }
}

internal extension DialogContentView {
  func setViewModel(_ viewModel: DialogViewModel) {
    self.viewModel = viewModel
  }
  
  /// Add tap to dismiss gesture on background view
  func addDismissGesture(_ gesture: UITapGestureRecognizer) {
    backgroundView.addGestureRecognizer(gesture)
  }
  
  func addScrollViewDelegate(_ delegate: UIScrollViewDelegate) {
    scrollView.delegate = delegate
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
    scrollView.bounces = false
    scrollView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func setupContent() {
    scrollView.addSubview(content)
    content.translatesAutoresizingMaskIntoConstraints = false
  }
}

private extension DialogContentView {
  func viewModelUpdated() {
    guard let viewModel else { return }
    let allConstraints = getPosition(viewModel.position) + getWidth(viewModel.width) + getHeight(viewModel.height)
    NSLayoutConstraint.activate(allConstraints)
    print(allConstraints)
  }
  
  /// Get array of NSLayoutConstraints for Dialog based on the provided ``DialogPosition``
  /// - Parameter position: ``DialogPosition``
  func getPosition(_ position: DialogPosition) -> [NSLayoutConstraint] {
    switch position {
    case .bottom:
      return getBottomStyleConstraints()
    case .top:
      return getTopStyleConstraints()
    case .center:
      return getCenterStyleConstraints()
    }
  }
  
  /// Get array of NSLayoutConstraints for ContentView based on the provided ``DialogContentWidth``
  /// - Parameter width: ``DialogContentWidth``
  func getWidth(_ width: DialogContentWidth) -> [NSLayoutConstraint] {
    switch width {
    case .normal:
      return getNormalWidthConstraints()
    case .customWidth(let width):
      return getCustomWidthConstraints(width)
    case .customInsets(let leading, let trailing):
      return getCustomInsetsConstraints(leading: leading, trailing: trailing)
    }
  }
  
  /// Get array of NSLayoutConstraints for ContentView based on the provided ``DialogContentHeight``
  /// - Parameter height: ``DialogContentHeight``
  func getHeight(_ height: DialogContentHeight) -> [NSLayoutConstraint] {
    switch height {
    case .normal:
      return getNormalHeightConstraints()
    case .customHeight(let height):
      return getCustomHeightConstraints(height)
    }
  }
}

// MARK: - ScrollView Constraints
private extension DialogContentView {
  func getBottomStyleConstraints() -> [NSLayoutConstraint] {
    let bottomAnchor = scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    bottomAnchor.priority = .required
    let topAnchor = scrollView.topAnchor.constraint(equalTo: self.topAnchor)
    topAnchor.priority = .init(rawValue: 1)
    return [scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomAnchor, topAnchor]
  }
  
  func getTopStyleConstraints() -> [NSLayoutConstraint] {
    let bottomAnchor = scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    bottomAnchor.priority = .init(rawValue: 1)
    let topAnchor = scrollView.topAnchor.constraint(equalTo: self.topAnchor)
    topAnchor.priority = .required
    return [scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            topAnchor, bottomAnchor]
  }
  
  func getCenterStyleConstraints() -> [NSLayoutConstraint] {
    let topAnchor = scrollView.topAnchor.constraint(equalTo: self.topAnchor)
    topAnchor.priority = .init(rawValue: 1)
    let bottomAnchor = scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    bottomAnchor.priority = .init(rawValue: 1)
    return [
      scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      scrollView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      topAnchor, bottomAnchor]
  }
}

// MARK: - ContentView width and height constraints
private extension DialogContentView {
  func getNormalWidthConstraints() -> [NSLayoutConstraint] {
    return [content.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            content.topAnchor.constraint(equalTo: scrollView.topAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.widthAnchor)]
  }
  
  func getCustomWidthConstraints(_ width: CGFloat) -> [NSLayoutConstraint] {
    return [content.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            content.topAnchor.constraint(equalTo: scrollView.topAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            content.widthAnchor.constraint(equalToConstant: width)]
  }
  
  func getCustomInsetsConstraints(leading: CGFloat, trailing: CGFloat) -> [NSLayoutConstraint] {
    let leadingAnchor = content.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leading)
    leadingAnchor.priority = .required
    let trailingAnchor = content.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: trailing)
    trailingAnchor.priority = .required
    let widthAnchor = content.widthAnchor.constraint(lessThanOrEqualTo: scrollView.widthAnchor)
    widthAnchor.priority = .defaultHigh
    return [content.topAnchor.constraint(equalTo: scrollView.topAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            leadingAnchor, trailingAnchor, widthAnchor]
  }
  
  func getNormalHeightConstraints() -> [NSLayoutConstraint] {
    [content.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)]
  }
  
  func getCustomHeightConstraints(_ height: CGFloat) -> [NSLayoutConstraint] {
    [scrollView.heightAnchor.constraint(equalToConstant: height),
     content.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)]
  }
}
