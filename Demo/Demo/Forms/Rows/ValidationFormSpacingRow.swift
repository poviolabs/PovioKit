//
//  ValidationFormSpacingRow.swift
//  Demo
//
//  Created by Toni Kocjan on 10/09/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit
import PovioKit

class ValidationFormSpacingRow: BaseValidationFormRowType {
  let height: CGFloat
  
  init(height: CGFloat) {
    self.height = height
  }
  
  func validationForm(_ validationForm: ValidationForm, cellForRowAt indexPath: IndexPath, in collectionView: UICollectionView) -> ValidationFormCell {
    let cell = collectionView.dequeueReusableCell(ValidationFormSpacingCell.self, at: indexPath)
    cell.update(height: height)
    return cell
  }
}
