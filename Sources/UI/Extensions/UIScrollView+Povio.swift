//
//  UIScrollView+Povio.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 02/02/2023.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import UIKit

public extension UIScrollView {
  var isScrolledAtTop: Bool {
    return contentOffset.y.rounded() <= verticalOffsetForTop.rounded()
  }
  
  var isScrolledAtBottom: Bool {
    return contentOffset.y.rounded() >= verticalOffsetForBottom.rounded()
  }
  
  var verticalOffsetForTop: CGFloat {
    return -adjustedContentInset.top
  }
  
  var verticalOffsetForBottom: CGFloat {
    let scrollViewHeight = bounds.height
    let scrollContentSizeHeight = contentSize.height
    let bottomInset = adjustedContentInset.bottom
    let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
    return scrollViewBottomOffset
  }
}
