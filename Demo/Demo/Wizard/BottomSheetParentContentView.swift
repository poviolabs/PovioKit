//
//  BottomSheetParentContentView.swift
//  Demo
//
//  Created by Marko Mijatovic on 13/04/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation
import SnapKit
import PovioKitUI
import UIKit

class BottomSheetParentContentView: BottomSheetContentView {
  override init() {
    super.init()
    setupViews()
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Private Methods
private extension BottomSheetParentContentView {
  func setupViews() {
    addSubview(contentView)
    contentView.snp.makeConstraints {
      $0.bottom.leading.trailing.equalToSuperview()
    }
  }
}
