//
//  KeychainService.swift
//  Facelift
//
//  Created by Domagoj Kulundzic on 04/07/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import Foundation

///
/// An abstraction for a predefined set of functionality, aimed to be ran once, at app startup.
///
public protocol StartupProcess {
  func run(completion: @escaping (Bool) -> Void)
}

extension StartupProcess {
  public var id: String {
    return UUID().uuidString
  }
}
