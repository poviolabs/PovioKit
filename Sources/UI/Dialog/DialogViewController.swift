//
//  Dialog.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 4/19/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import UIKit

/// Dialog component - Present custom view in a UIAlertController alternative.
///
/// Subclass and present it as any other UIViewController
///
/// - Size will be dynamically adjusted based on the content (it will scroll if needed)
/// - Define presenting animation and screen position
///```swift
///// Example:
///class DialogExampleViewController: DialogViewController<DialogContentView> {
///  override init(contentView: DialogContentView, position: DialogPosition, animation: DialogAnimationType?) {
///    super.init(contentView: contentView, position: position, animation: animation)
///  } ...
/// }
///
/// let dialog = DialogExampleViewController(contentView: DialogExampleContentView(), position: .top, animation: .fade)
/// self.navigationController?.present(dialog, animated: true)
///```
open class DialogViewController<ContentView: DialogContentView>: UIViewController {
  public let contentView: ContentView
  private let position: DialogPosition
  private let contentWidth: DialogContentWidth
  private let transitionDelegate: DialogTransitionDelegate
  
  /// Init
  /// - Parameters:
  ///   - contentView: ``DialogContentView`` UIView that holds user-defined custom UI
  ///   - position: ``DialogPosition`` - Dialog position on the screen
  ///   - width: ``DialogContentView`` - Create dialog with specific width
  ///   - animation: ``DialogAnimationType`` (**optional**) it can be one of the predefined animations, custom or .none
  public init(contentView: ContentView,
              position: DialogPosition = .bottom,
              width: DialogContentWidth = .normal,
              animation: DialogAnimationType? = .none) {
    self.contentView = contentView
    self.position = position
    self.contentWidth = width
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
private extension DialogViewController {
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
    contentView.setContentWidth(contentWidth)
  }
  
  /// Add tap to dismiss gesture
  func addGesture() {
    let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
    contentView.addDismissGesture(dismissGesture)
  }
}
