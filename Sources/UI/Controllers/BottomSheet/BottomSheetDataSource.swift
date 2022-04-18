//
//  BottomSheetDataSource.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 13/04/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation

/// Class that holds a list of all Steps and is handling navigation from Step to Step (next and previous)
public class BottomSheetDataSource: NSObject {
  public typealias LazyStep = () -> BottomSheetStep
  
  var currentStepIndex = -1
  var currentStep: BottomSheetStep?
  var steps: [LazyStep]
  
  init(steps: [LazyStep]) {
    self.steps = steps
  }
}

public extension BottomSheetDataSource {
  func nextStep() -> BottomSheetStep? {
    currentStepIndex += 1
    guard currentStepIndex < steps.count else {
      currentStepIndex -= 1
      return nil
    }
    let thunk = steps[currentStepIndex]
    let step = thunk()
    self.currentStep = step
    return step
  }
  
  func previousStep() -> BottomSheetStep? {
    currentStepIndex -= 1
    guard currentStepIndex >= 0 else {
      currentStepIndex += 1
      return nil
    }
    let thunk = steps[currentStepIndex]
    let step = thunk()
    self.currentStep = step
    return step
  }
}
