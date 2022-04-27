//
//  Dialog.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 4/19/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import UIKit

open class Dialog<ContentView: DialogContentView>: UIViewController {
  public let contentView: ContentView
  private let position: DialogPosition
  private let transitionDelegate: DialogTransitionDelegate
  
  public init(contentView: ContentView, position: DialogPosition, animation: DialogAnimationType? = .none) {
    self.contentView = contentView
    self.position = position
    self.transitionDelegate = DialogTransitionDelegate(animation: animation)
    super.init(nibName: nil, bundle: nil)
    self.transitioningDelegate = transitionDelegate
    self.modalPresentationStyle = .overCurrentContext
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  @objc func dismissDialog() {
    dismiss(animated: true)
  }
}

// MARK: - Private Methods
private extension Dialog {
  func setupViews() {
    setupContentView()
    addGesture()
  }
  
  func setupContentView() {
    view.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      contentView.topAnchor.constraint(equalTo: view.topAnchor)
    ])
    contentView.setPosition(position)
  }
  
  func addGesture() {
    let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
    contentView.addDismissGesture(dismissGesture)
  }
}
