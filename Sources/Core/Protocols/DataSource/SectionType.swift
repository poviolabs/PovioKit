//
//  SectionType.swift
//  PovioKit
//
//  Created by Egzon Arifi on 09/03/2021.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "Please migrate to diffable datasource instead.")
public protocol SectionType {
  associatedtype Row: RowType
  var rows: [Row] { get }
}

@available(*, deprecated, message: "Please migrate to diffable datasource instead.")
public extension SectionType {
  func row(at index: Int) -> Self.Row? {
    rows[safe: index]
  }
}
