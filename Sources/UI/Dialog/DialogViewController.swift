//
//  Dialog.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 4/19/22.
//  Copyright © 2023 Povio Inc. All rights reserved.
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
open class DialogViewController<ContentView: DialogContentView>: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
  public let contentView: ContentView
  private let viewModel: DialogViewModel
  private let enableSwipeGesture: Bool
  private let transitionDelegate: DialogTransitionDelegate
  private var verticalTranslation: CGFloat = .zero
  
  /// Init
  /// - Parameters:
  ///   - contentView: ``DialogContentView`` UIView that holds user-defined custom UI
  ///   - position: ``DialogPosition`` - Dialog position on the screen
  ///   - width: ``DialogContentView`` - Create dialog with specific width
  ///   - enableSwipeToDismiss: ``Bool`` - Flag to enable swipe to dismiss gesture. If true, we will track swipe gestures outside of the dialog content view or scroll to the top if the content view is covering the whole screen.
  ///   - animation: ``DialogAnimationType`` (**optional**) it can be one of the predefined animations, custom or .none
  public init(contentView: ContentView,
              viewModel: DialogViewModel,
              enableSwipeToDismiss: Bool = true,
              animation: DialogAnimationType? = .none) {
    self.contentView = contentView
    self.viewModel = viewModel
    self.enableSwipeGesture = enableSwipeToDismiss
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
  
  open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
    if viewModel.position == .top {
      topPositionDismissAnimation(completion)
    } else {
      super.dismiss(animated: flag, completion: completion)
    }
  }
  
  /// We need to enable the pan gesture and the scrollView gesture to work at the same time.
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  @objc func tapToDismiss() {
    dismiss(animated: true)
  }
  
  @objc func swipeToDismiss(sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .changed:
      verticalTranslation = sender.translation(in: view).y
      guard viewModel.shouldAnimateTranslation(verticalTranslation) else { return }
      translateContentAnimated()
    case .ended:
      viewModel.shouldAnimateReturn(verticalTranslation) ? returnContentAnimated() : dismissWithCustomAnimation()
    default:
      break
    }
  }
}

// MARK: - Private Methods - Setup
private extension DialogViewController {
  func setupViews() {
    setupContentView()
    addGestures()
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
    contentView.setViewModel(viewModel)
    if enableSwipeGesture {
      contentView.addScrollViewDelegate(self)
    }
  }
  
  /// Add tap and pan to dismiss gesture
  func addGestures() {
    let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss))
    contentView.addDismissGesture(dismissGesture)
    if enableSwipeGesture {
      let panGesture = UIPanGestureRecognizer(target: self, action: #selector(swipeToDismiss))
      panGesture.delegate = self
      self.view.addGestureRecognizer(panGesture)
    }
  }
}

// MARK: - Private Methods - Animations
private extension DialogViewController {
  func translateContentAnimated() {
    UIView.animate(withDuration: 0.3, delay: 0, animations: {
      self.view.transform = CGAffineTransform(translationX: 0, y: self.verticalTranslation)
    })
  }
  
  func returnContentAnimated() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.view.transform = .identity
    })
  }
  
  func dismissWithCustomAnimation() {
    UIView.animate(withDuration: 0.3, delay: 0, animations: {
      self.view.transform = CGAffineTransform(translationX: 0, y: self.verticalTranslation + self.viewModel.swipeAnimationLimit)
    }, completion: { _ in
      self.dismiss(animated: false)
    })
  }
  
  func topPositionDismissAnimation(_ completion: (() -> Void)?) {
    UIView.animate(withDuration: 0.3, delay: 0, animations: {
      self.view.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
    }, completion: { _ in
      super.dismiss(animated: false, completion: completion)
    })
  }
}
