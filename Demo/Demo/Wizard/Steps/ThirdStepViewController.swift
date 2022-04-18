//
//  ThirdStepViewController.swift
//  Demo
//
//  Created by Marko Mijatovic on 13/04/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation
import UIKit

class ThirdStepViewController: UIViewController, StepViewController {
  private lazy var contentView = ThirdStepContentView()
  var wizard: MainBottomSheet?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  override func loadView() {
    view = contentView
  }
  
  func didTapNextButton() {}
  
  func didTapPreviousButton() {
    print("back")
    self.wizard?.previousStep()
  }
}

// MARK: - Private Methods
private extension ThirdStepViewController {
  func setupViews() {
    setupContentView()
  }
  
  func setupContentView() {
    contentView.backButtonCallback = didTapPreviousButton
  }
}
