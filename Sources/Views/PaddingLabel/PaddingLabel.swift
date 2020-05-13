//
//  PaddingLabel.swift
//  PovioKit
//
//  Created by Borut Tomažin on 13/05/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit

/// A UILabel subclass with configurable `contentInset`.
class PaddingLabel: UILabel {
  var contentInset: UIEdgeInsets = .init(all: 5) {
    didSet { invalidateIntrinsicContentSize() }
  }
  
  override func drawText(in rect: CGRect) {
    super.drawText(in: rect.inset(by: contentInset))
  }
  
  override var intrinsicContentSize: CGSize {
    var contentSize = super.intrinsicContentSize
    contentSize.height += contentInset.vertical
    contentSize.width += contentInset.horizontal
    return contentSize
  }
}
