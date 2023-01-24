//
//  MockBundleReader.swift
//  PovioKit
//
//  Created by Egzon Arifi on 31/03/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation
import PovioKitCore

class MockBundleReader: BundleReadable {
  private let dictionary: [String: Any]
  
  init(dictionary: [String: Any]) {
    self.dictionary = dictionary
  }
  
  func object(forInfoDictionaryKey key: String) -> Any? {
    dictionary[key]
  }
}
