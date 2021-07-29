//
//  ValidationFormCheckboxCell.swift
//  Demo
//
//  Created by Toni Kocjan on 10/09/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit
import PovioKit

class ValidationFormCheckboxCell: DynamicCollectionCell, ValidationFormCell {
  private let checkboxButton = UIButton()
  private let label = UILabel()
  var didToggleCallback = Delegated<Bool, ()>()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ValidationFormCheckboxCell {
  func update<R: ValidationFormCheckboxRow>(using row: R) {
    checkboxButton.isSelected = row.validationStatus.isValid
    switch row.text {
    case .normal(let text):
      label.text = text
    case .attributed(let attributedString):
      label.attributedText = attributedString
    }
    switch row.validationStatus {
    case .valid:
      checkboxButton.applyBorder(color: .green, width: 1)
    case .pending:
      checkboxButton.applyBorder(color: .black, width: 1)
    case .invalid:
      checkboxButton.applyBorder(color: .red, width: 1)
    }
  }
}

private extension ValidationFormCheckboxCell {
  func setupViews() {
    setupCheckboxButton()
    setupLabel()
  }

  func setupCheckboxButton() {
    contentView.addSubview(checkboxButton)
    checkboxButton.addTarget(self, action: #selector(didTapCheckboxButton), for: .touchUpInside)
    checkboxButton.setImage(.named("checkboxIcon"), for: .selected)
    checkboxButton.setImage(.named("checkboxEmpty"), for: .normal)
    checkboxButton.snp.makeConstraints {
      $0.top.bottom.leading.equalToSuperview()
      $0.size.equalTo(34).priority(.medium)
    }
  }

  func setupLabel() {
    contentView.addSubview(label)
    label.numberOfLines = 2
    label.snp.makeConstraints {
      $0.leading.equalTo(checkboxButton.snp.trailing).offset(20)
      $0.trailing.equalTo(-20)
      $0.centerY.equalTo(checkboxButton.snp.centerY)
    }
  }
  
  @objc func didTapCheckboxButton() {
    checkboxButton.isSelected.toggle()
    didToggleCallback(checkboxButton.isSelected)
  }
}
