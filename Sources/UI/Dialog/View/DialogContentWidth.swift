//
//  DialogContentWidth.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 10/14/22.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation

public enum DialogContentWidth {
  case normal
  case customWidth(CGFloat)
  case customInsets(leading: CGFloat, trailing: CGFloat)
}
