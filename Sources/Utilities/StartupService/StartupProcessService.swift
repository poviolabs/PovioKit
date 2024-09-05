//
//  StartupProcessService.swift
//  PovioKit
//
//  Created by Domagoj Kulundzic on 26/04/2019.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

public final class StartupProcessService {
  public init() {}
  
  public var persistingProcesses = [StartupableProcess & PersistableProcess]()
  
  @discardableResult
  @available(*, deprecated, message: "Use `execute(process: StartupableProcess` instead with new process types.")
  public func execute(process: StartupProcess) -> StartupProcessService {
    process.run { _ in }
    return self
  }
  
  public func execute(process: StartupableProcess) -> StartupProcessService {
    process.run()
    if let process = process as? (StartupableProcess & PersistableProcess) {
      persistingProcesses.append(process)
    }
    return self
  }
}
