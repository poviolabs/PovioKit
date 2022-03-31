//
//  BundleReadable.swift
//  PovioKit
//
//  Created by Egzon Arifi on 31/03/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public protocol BundleReadable {
  func object(forInfoDictionaryKey key: String) -> Any?
}
