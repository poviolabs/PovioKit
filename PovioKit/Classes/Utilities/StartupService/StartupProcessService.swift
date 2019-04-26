//
//  StartupProcessService.swift
//  Facelift
//
//  Created by Domagoj Kulundzic on 04/07/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import Foundation

public final class StartupProcessService {
  @discardableResult
  public func execute(process: StartupProcess) -> StartupProcessService {
    process.run { (success) in
      guard success else { return }
      print("Successfully ran the \(type(of: process)) process.")
    }
    return self
  }
}
