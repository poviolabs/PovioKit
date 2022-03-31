//
//  BundleReader.swift
//  PovioKit
//
//  Created by Egzon Arifi on 31/03/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public class BundleReader: BundleReadable {
  private let bundle: Bundle
  
  public init(bundle: Bundle = .main) {
    self.bundle = bundle
  }
  
  public func object(forInfoDictionaryKey key: String) -> Any? {
    bundle.object(forInfoDictionaryKey: key)
  }
}
