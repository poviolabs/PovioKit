//
//  ValidationFormSpacingCell.swift
//  Demo
//
//  Created by Toni Kocjan on 10/09/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit
import PovioKit

class ValidationFormSpacingCell: DynamicCollectionCell, ValidationFormCell {
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.snp.makeConstraints {
      $0.height.equalTo(0)
      $0.edges.equalToSuperview().priority(.medium)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ValidationFormSpacingCell {
  func update(height: CGFloat) {
    contentView.snp.updateConstraints {
      $0.height.equalTo(height)
    }
  }
}
