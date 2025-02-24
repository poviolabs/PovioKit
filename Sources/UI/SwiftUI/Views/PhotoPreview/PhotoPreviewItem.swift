//
//  PhotoPreviewItem.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 12/08/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

public struct PhotoPreviewItem {
  public var image: Image?
  public var url: URL?
  public var placeholder: Image?
  
  public init(
    image: Image? = nil,
    url: URL? = nil,
    placeholder: Image? = nil
  ) {
    self.image = image
    self.url = url
    self.placeholder = placeholder
  }
}
