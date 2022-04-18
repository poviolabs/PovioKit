//
//  StartupProcessService.swift
//  PovioKit
//
//  Created by Domagoj Kulundzic on 26/04/2019.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public final class StartupProcessService {
  public init() {}
  
  @discardableResult
  public func execute(process: StartupProcess) -> StartupProcessService {
    process.run { guard $0 else { return } }
    return self
  }
}
