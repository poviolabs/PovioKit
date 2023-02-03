//
//  DialogExampleViewController.swift
//  Demo
//
//  Created by Marko Mijatovic on 4/21/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import PovioKitUI
import UIKit

class DialogExampleViewController: DialogViewController<DialogContentView> {
  override init(contentView: DialogContentView,
                viewModel: DialogViewModel = DialogViewModel(),
                enableSwipeToDismiss: Bool = true,
                animation: DialogAnimationType? = .none) {
    super.init(contentView: contentView, viewModel: viewModel, enableSwipeToDismiss: enableSwipeToDismiss, animation: animation)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
}

// MARK: - Private Methods
private extension DialogExampleViewController {
  func setupViews() {
    (contentView as? DialogExampleContentView)?.doneCallback = {
      self.dismiss(animated: true)
    }
  }
}
