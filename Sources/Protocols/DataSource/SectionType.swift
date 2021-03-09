//
//  SectionType.swift
//  PovioKit
//
//  Created by Egzon Arifi on 09/03/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import Foundation

public protocol SectionType {
  associatedtype Row: RowType
  var rows: [Row] { get }
}

public extension SectionType {
  func row(at index: Int) -> Self.Row? {
    rows[safe: index]
  }
}
