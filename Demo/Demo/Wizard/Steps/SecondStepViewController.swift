//
//  SecondStepViewController.swift
//  Demo
//
//  Created by Marko Mijatovic on 13/04/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation
import UIKit

class SecondStepViewController: UIViewController, StepViewController {
  private lazy var contentView = SecondStepContentView()
  var wizard: MainBottomSheet?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  override func loadView() {
    view = contentView
  }
  
  func didTapNextButton() {
    print("next")
    self.wizard?.nextStep()
  }
  
  func didTapPreviousButton() {
    print("back")
    self.wizard?.previousStep()
  }
}

// MARK: - Private Methods
private extension SecondStepViewController {
  func setupViews() {
    setupContentView()
  }
  
  func setupContentView() {
    contentView.nextButtonCallback = didTapNextButton
    contentView.backButtonCallback = didTapPreviousButton
  }
}
