//
//  DialogContentView.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 4/19/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import UIKit

open class DialogContentView: UIView {
  private let backgroundView = UIView()
  private let scrollView = UIScrollView()
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
      content.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      content.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
    ])
    content.layoutIfNeeded()
  }
}

// MARK: - ScrollView Constraints
private extension DialogContentView {
  func setBottomStyleConstraints() {
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
  }
  
  func setTopStyleConstraints() {
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: self.topAnchor)
    ])
  }
  
  func setCenterStyleConstraints() {
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      scrollView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    ])
  }
}
