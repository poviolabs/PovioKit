//
//  FirstStepViewController.swift
//  Demo
//
//  Created by Marko Mijatovic on 13/04/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation
import UIKit

class FirstStepViewController: UIViewController, StepViewController {
  private lazy var contentView = FirstStepContentView()
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
  
  func didTapPreviousButton() { }
}

// MARK: - Private Methods
private extension FirstStepViewController {
  func setupViews() {
    setupContentView()
  }
  
  func setupContentView() {
    contentView.nextButtonCallback = didTapNextButton
  }
}
