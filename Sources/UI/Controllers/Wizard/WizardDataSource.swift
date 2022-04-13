//
//  WizardDataSource.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 13/04/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation

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
      currentStepIndex -= 1
      return nil
    }
    let step = thunk()
    self.currentStep = step
    return step
  }
  
  func previousStep() -> WizardStep? {
    currentStepIndex -= 1
    guard let thunk = steps[safe: currentStepIndex] else {
      currentStepIndex += 1
      return nil
    }
    let step = thunk()
    self.currentStep = step
    return step
  }
}
