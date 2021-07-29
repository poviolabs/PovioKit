//
//  ValidationFormInputRow.swift
//  Demo
//
//  Created by Toni Kocjan on 31/08/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit
import PovioKit

final class ValidationFormInputRow: ValidatableValidationFormRowType {
  typealias Value = String
  typealias ValidationStatus = DefaultValidationStatus
  
  var validationStatus = ValidationStatus.pending(())
  var value: String?
  let validator: Validator
  let key: String?
  let placeholder: String?
  
  private let cellConfigurator: ((ValidationFormInputCell) -> Void)?
  private let valueDidChange: ((String?) -> Void)?
  private let onCellTap: (() -> Void)?
  
  init(
    value: String? = nil,
    key: String?,
    placeholder: String?,
    validator: @escaping Validator,
    cellConfigurator: ((ValidationFormInputCell) -> Void)? = nil,
    valueDidChange: ((String?) -> Void)? = nil,
    onCellTap: (() -> Void)? = nil
  ) {
    self.value = value
    self.key = key
    self.placeholder = placeholder
    self.validator = validator
    self.cellConfigurator = cellConfigurator
    self.valueDidChange = valueDidChange
    self.onCellTap = onCellTap
  }
  
  func validationForm(_ validationForm: ValidationForm, cellForRowAt indexPath: IndexPath, in collectionView: UICollectionView) -> ValidationFormCell {
    let cell = collectionView.dequeueReusableCell(ValidationFormInputCell.self, at: indexPath)
    cell.update(using: self)
    cell.valueDidChangeCallback.delegate(to: self) { (self, value) in // swiftlint:disable:this unneeded_parentheses_in_closure_argument
      validationForm.updateRow(ValidationFormInputRow.self, value: value, at: indexPath)
      self.map(cell.update)
      self?.valueDidChange?(value)
    }
    cell.didSelectCallback.delegate(to: self) { (self) in
      self?.onCellTap?()
    }
    cellConfigurator?(cell)
    return cell
  }
}
