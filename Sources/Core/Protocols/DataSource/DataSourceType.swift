//
//  DataSourceType.swift
//  PovioKit
//
//  Created by Egzon Arifi on 09/03/2021.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "Please migrate to diffable datasource instead.")
public protocol DataSourceType {
  associatedtype Section: SectionType
  var sections: [Section] { get set }
}

@available(*, deprecated, message: "Please migrate to diffable datasource instead.")
public extension DataSourceType {
  func numberOfSections() -> Int {
    sections.count
  }
  
  func numberOfRows(in section: Int) -> Int {
    sections[safe: section]?.rows.count ?? 0
  }
  
  func section(at index: Int) -> Section? {
    sections[safe: index]
  }
  
  subscript(_ indexPath: IndexPath) -> Section.Row? {
    section(at: indexPath.section)?.row(at: indexPath.row)
  }
  
  func isLastRow(indexPath: IndexPath) -> Bool {
    indexPath.section == (sections.count - 1) && indexPath.row == (sections.last?.rows.count ?? 0) - 1
  }
  
  func isLastRow(_ rowIndex: Int, in section: Self.Section) -> Bool {
    rowIndex == (section.rows.count - 1)
  }
}
