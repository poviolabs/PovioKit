//
//  StartupProcessService.swift
//  PovioKit
//
//  Created by Domagoj Kulundzic on 26/04/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation

public final class StartupProcessService {
  public init() {}
  
  @discardableResult
  public func execute(process: StartupProcess) -> StartupProcessService {
    process.run { (success) in
      guard success else { return }
      print("Successfully ran the \(type(of: process)) process.")
    }
    return self
  }
}
