//
//  ValidationForm.swift
//  PovioKit
//
//  Created by Toni Kocjan on 08/08/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import UIKit

open class ValidationForm: NSObject, UICollectionViewDataSource {
  private var form: [BaseValidationFormRowType] = []
  
  public init(@ValidationFormBuilder build: () -> [BaseValidationFormRowType]) {
    self.form = build()
  }
  
  public override init() {
    self.form = []
    super.init()
  }
  
  // MARK: - UICollectionViewDataSource
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    1
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    form.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let row = form[safe: indexPath.row] else {
      fatalError("No row at `\(indexPath)`!")
    }
    return row.validationForm(self, cellForRowAt: indexPath, in: collectionView)
  }
}

// MARK: - API
public extension ValidationForm {
  @discardableResult
  func validate(in collectionView: UICollectionView) -> Bool {
    for row in form {
      row.validate()
    }
    collectionView.reloadDataKeepingContentOffset()
    return isFormValid
  }
  
  func validateRow(at index: Int, in collectionView: UICollectionView) -> Bool {
    guard let row = form[safe: index] else { return true }
    row.validate()
    collectionView.reloadDataKeepingContentOffset()
    return isRowValid(row)
  }
  
  func validateRow(key: String, in collectionView: UICollectionView) -> Bool {
    guard let rowIndex = form.firstIndex(where: { $0.key == key }) else { return true }
    return validateRow(at: rowIndex, in: collectionView)
  }
  
  var isFormValid: Bool {
    form.allSatisfy(isRowValid)
  }
  
  func generate<D: Decodable>(_ model: D.Type, decoder: JSONDecoder) throws -> D {
    let json = form
      .compactMap { $0.keyValuePair }
      .reduce(into: [String: Any]()) { $0.updateValue($1.value, forKey: $1.key) }
      .filter { !(($0.value as? String)?.isEmpty ?? true) }
    let data = try JSONSerialization.data(withJSONObject: json, options: [])
    return try decoder.decode(model, from: data)
  }
  
  func populateForm<T>(_ model: T, in collectionView: UICollectionView) {
    for (label, value) in Mirror(reflecting: model).children {
      guard let label = label else { continue }
      guard let row = form.first(where: { $0.key == label }) else { continue }
      row.updateValue(value)
    }
    collectionView.reloadDataKeepingContentOffset()
  }
  
  func row<Value, Status, R: ValidatableValidationFormRowType>(
    at index: Int
  ) -> R? where R.Value == Value, R.ValidationStatus == Status {
    form[safe: index] as? R
  }
  
  func updateRow<R: ValidatableValidationFormRowType>(
    _ type: R.Type,
    value: R.Value?,
    at indexPath: IndexPath
  ) {
    guard let row: R = row(at: indexPath.row) else { return }
    row.updateValue(value)
    row.validate()
  }
  
  func updateRow(key: String, value: Any?, in collectionView: UICollectionView) {
    guard let rowIndex = rowIndex(key: key) else { return }
    form[rowIndex].updateValue(value)
    form[rowIndex].validate()
    collectionView.reloadItems(at: [.init(row: rowIndex, section: 0)])
  }
  
  func updateValidationStatus<R: ValidatableValidationFormRowType>(
    _ type: R.Type,
    key: String,
    validationStatus: R.ValidationStatus,
    in collectionView: UICollectionView
  ) {
    guard let rowIndex = rowIndex(key: key) else { return }
    guard let row = form[rowIndex] as? R else { return }
    row.validationStatus = validationStatus
    collectionView.reloadItems(at: [.init(row: rowIndex, section: 0)])
  }
  
  func appendRow<R: BaseValidationFormRowType>(_ row: R) {
    form.append(row)
  }
  
  func appendRows(_ rows: [BaseValidationFormRowType]) {
    form.append(contentsOf: rows)
  }
  
  func appendRows(_ rows: BaseValidationFormRowType...) {
    form.append(contentsOf: rows)
  }
  
  func rowIndex(key: String) -> Int? {
    form.firstIndex { $0.key == key }
  }
  
  subscript(indexPath: IndexPath) -> BaseValidationFormRowType? {
    form[safe: indexPath.row]
  }
}

extension ValidationForm {
  func isRowValid(_ row: BaseValidationFormRowType) -> Bool {
    for (label, value) in Mirror(reflecting: row).children {
      guard label == "validationStatus", let valid = value as? IsValid else { continue }
      return valid.isValid
    }
    return true
  }
}

extension UICollectionView {
  func reloadDataKeepingContentOffset() {
    let contentOffset = self.contentOffset
    reloadData()
    layoutIfNeeded()
    DispatchQueue.main.async {
      self.setContentOffset(contentOffset, animated: false)
    }
  }
}
