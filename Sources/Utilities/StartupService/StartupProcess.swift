//
//  StartupProcess.swift
//  PovioKit
//
//  Created by Domagoj Kulundzic on 26/04/2019.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

/// An abstraction for a predefined set of functionality, aimed to be ran once, at app startup.
@available(*, deprecated, message: "The `StartupProcess` protocol with `run(:completion)` is deprecated. Instead, use `StartupableProcess` with `run()` only.")
public protocol StartupProcess {
  func run(completion: @escaping (Bool) -> Void)
}

public protocol StartupableProcess {
  func run()
}

public protocol PersistableProcess {}
