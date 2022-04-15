//
//  BottomSheet.swift
//  PovioKit
//
//  Created by Toni Kocjan on 29/09/2021.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation
import UIKit

public protocol BottomSheetStep: UIViewController { }

/// An automatically resizable dialog superclass.
///
/// This view controller enables you to add and transition
/// between view controllers inside a dialog.
/// The UI, presentation, and layout are completely decoupled,
/// allowing for maximum specialization.
///
open class BottomSheet<ContentView: BottomSheetContentView>: UIViewController {
  public typealias DataSource = BottomSheetDataSource
  public typealias LazyStep = DataSource.LazyStep
  
  public let contentView: ContentView
  let dataSource: DataSource
  
  public init(steps: [LazyStep], mainContentView: ContentView) {
    self.contentView = mainContentView
    self.dataSource = .init(steps: steps)
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  override open func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews() 
    initialStep()
  }
  
  open func configureStep(beforeTransition step: BottomSheetStep) {
    /// Override in subclass if necessary
  }
  
  @objc func tapOutsideToDismiss(gesture: UITapGestureRecognizer) {
    dismiss(animated: true)
  }
}

// MARK: - API
public extension BottomSheet {
  func addStep(_ step: @escaping LazyStep) {
    dataSource.steps.append(step)
  }
  
  func insertStep(_ step: @escaping LazyStep, at index: Int) {
    dataSource.steps.insert(step, at: index)
    if dataSource.currentStepIndex > index {
      dataSource.currentStepIndex += 1
    }
  }
  
  func insertStep(afterCurrentStep step: @escaping LazyStep) {
    insertStep(step, at: dataSource.currentStepIndex + 1)
  }
  
  func addSteps(_ steps: LazyStep...) {
    dataSource.steps.append(contentsOf: steps)
  }
  
  func addSteps<C: Collection>(_ steps: C) where C.Element == LazyStep {
    dataSource.steps.append(contentsOf: steps)
  }
  
  var currentStep: BottomSheetStep? {
    dataSource.currentStep
  }

  func nextStep(
    transitionDuration duration: TimeInterval,
    animator: AnimatorFactory.Animator?
  ) {
    guard !contentView.isPerformingLayout else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.nextStep(transitionDuration: duration, animator: animator)
      }
      return
    }
    
    guard let step = dataSource.nextStep() else { return }
    configureStep(beforeTransition: step)
    
    view.isUserInteractionEnabled = false
    contentView.transitionToView(
      step.view,
      transitionDuration: duration,
      animate: animator,
      completion: { [weak view] in view?.isUserInteractionEnabled = true }
    )
  }
  
  func previousStep(
    transitionDuration duration: TimeInterval,
    animator: AnimatorFactory.Animator?
  ) {
    guard !contentView.isPerformingLayout else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.previousStep(transitionDuration: duration, animator: animator)
      }
      return
    }
    
    guard let step = dataSource.previousStep() else { return }
    configureStep(beforeTransition: step)
    
    view.isUserInteractionEnabled = false
    contentView.transitionToView(
      step.view,
      transitionDuration: duration,
      animate: animator,
      completion: { [weak view] in view?.isUserInteractionEnabled = true }
    )
  }
}

// MARK: - Private Methods
private extension BottomSheet {
  func setupViews() {
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOutsideToDismiss)))
    setupContentView()
  }
  
  func setupContentView() {
    view.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      contentView.topAnchor.constraint(equalTo: view.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  func initialStep() {
    guard dataSource.currentStepIndex < 0 else { return }
    nextStep(transitionDuration: 0.3, animator: nil)
  }
}
