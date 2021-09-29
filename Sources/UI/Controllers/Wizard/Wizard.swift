//
//  File.swift
//  
//
//  Created by Toni Kocjan on 29/09/2021.
//

import Foundation
import UIKit

public protocol WizardStep: UIViewController {
}

public class WizardDataSource: NSObject {
  public typealias LazyStep = () -> WizardStep
  
  var currentStepIndex = -1
  var currentStep: WizardStep?
  var steps: [LazyStep]
  
  init(steps: [LazyStep]) {
    self.steps = steps
  }
}

public extension WizardDataSource {
  func nextStep() -> WizardStep? {
    currentStepIndex += 1
    guard let thunk = steps[safe: currentStepIndex] else {
      return nil
    }
    let step = thunk()
    self.currentStep = step
    return step
  }
}


open class Wizard<ContentView: WizardContentView>: UIViewController {
  public typealias DataSource = WizardDataSource
  public typealias LazyStep = DataSource.LazyStep
  
  public let contentView: ContentView
  let dataSource: DataSource
  
  public init(
    steps: [LazyStep],
    contentView: ContentView
  ) {
    self.contentView = contentView
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
  
  open func configureStep(beforeTransition step: WizardStep) {
    /// Override in subclass
  }
}

public extension Wizard {
  func addStep(_ step: @escaping LazyStep) {
    dataSource.steps.append(step)
  }
  
  func removeStep(at index: Int) {
    guard dataSource.steps.indices.contains(index) else { return }
    dataSource.steps.remove(at: index)
  }
  
  var currentStep: WizardStep? {
    dataSource.currentStep
  }
}

// MARK: - API
public extension Wizard {
  func nextStep() {
    guard !contentView.isPerformingLayout else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: nextStep)
      return
    }
    
    guard let step = dataSource.nextStep() else { return }
    configureStep(beforeTransition: step)
    
    view.isUserInteractionEnabled = false
    contentView.transitionToView(
      step.view,
      animate: { current, next in
        next.transform = CGAffineTransform.identity.translatedBy(x: current.frame.width, y: 0)
        UIView.animate(
          withDuration: 0.2,
          animations: {
            next.transform = .identity
            current.transform = CGAffineTransform.identity.translatedBy(x: -current.frame.width, y: 0)
          }
        )
        
//        next.alpha = 0
//        UIView.animate(
//          withDuration: 0.2,
//          animations: {
//            next.alpha = 1
//            current.alpha = 0
//          }
//        )
      },
      completion: { [weak self] in self?.view.isUserInteractionEnabled = true }
    )
  }
}

// MARK: - Private Methods
private extension Wizard {
  func setupViews() {
    setupContentView()
  }
  
  func setupContentView() {
    view.addSubview(contentView)
    view.translatesAutoresizingMaskIntoConstraints = false
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
    nextStep()
  }
}
