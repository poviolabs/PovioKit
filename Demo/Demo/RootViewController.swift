//
//  RootViewController.swift
//  Demo
//
//  Created by Marko Mijatovic on 13/04/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import UIKit
import PovioKitUI

class RootViewController: UIViewController {
  private let titleLabel = UILabel()
  private let backgroundImage = UIImageView()
  private let actionButton = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    setupContentView()
    openBottomSheet()
  }
}

private extension RootViewController {
  func setupContentView() {
    setupImage()
    setupTitleLabel()
    setupActionButton()
  }
  
  func setupImage() {
    view.addSubview(backgroundImage)
    backgroundImage.image = UIImage(named: "Background")
    backgroundImage.contentMode = .scaleAspectFill
    backgroundImage.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  func setupTitleLabel() {
    view.addSubview(titleLabel)
    titleLabel.font = .systemFont(ofSize: 28)
    titleLabel.textColor = .white
    titleLabel.textAlignment = .center
    titleLabel.text = "Bottom Sheet Demo"
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(140)
      $0.leading.trailing.equalToSuperview()
    }
  }
  
  func setupActionButton() {
    view.addSubview(actionButton)
    actionButton.setTitle("Open", for: .normal)
    actionButton.setTitleColor(.darkText, for: .normal)
    actionButton.addTarget(self, action: #selector(openBottomSheet), for: .touchUpInside)
    actionButton.backgroundColor = .init(red: 255, green: 250, blue: 76).withAlphaComponent(0.9)
    actionButton.layer.cornerRadius = 8
    actionButton.snp.makeConstraints {
      $0.width.equalTo(100)
      $0.height.equalTo(50)
      $0.centerX.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(40)
    }
  }
  
  @objc func openBottomSheet() {
    let firstStep: () -> BottomSheetStep = {
      FirstStepViewController()
    }
    let secondStep: () -> BottomSheetStep = {
      SecondStepViewController()
    }
    let thirdStep: () -> BottomSheetStep = {
      ThirdStepViewController()
    }
    let mainVC = BottomSheetViewController(steps: [firstStep, secondStep, thirdStep])
    navigationController?.present(mainVC, animated: true)
  }
}
