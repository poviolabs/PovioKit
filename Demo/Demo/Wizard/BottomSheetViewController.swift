//
//  BottomSheetViewController.swift
//  Demo
//
//  Created by Marko Mijatovic on 13/04/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation
import UIKit
import PovioKitUI

protocol MainBottomSheet: UIViewController {
  func dismissBottomSheet()
  func nextStep()
  func previousStep()
}

class BottomSheetViewController: BottomSheet<BottomSheetContentView> {
  init(steps: [BottomSheet<BottomSheetContentView>.LazyStep]) {
    super.init(steps: steps, mainContentView: BottomSheetParentContentView())
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func configureStep(beforeTransition step: BottomSheetStep) {
    (step as? StepViewController)?.wizard = self
  }
}

extension BottomSheetViewController: MainBottomSheet {
  func dismissBottomSheet() { dismiss(animated: true) }
  
  func nextStep() {
    nextStep(transitionDuration: 0.5, animator: BottomSheet.AnimatorFactory.myAnimation(animationDuration: 1))
  }
  
  func previousStep() {
    previousStep(transitionDuration: 0.5,
                 animator: BottomSheet.AnimatorFactory.fadeIn(animationDuration: 1))
  }
}
