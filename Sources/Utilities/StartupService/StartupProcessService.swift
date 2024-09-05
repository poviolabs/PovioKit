//
//  StartupProcessService.swift
//  PovioKit
//
//  Created by Domagoj Kulundzic on 26/04/2019.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

/// Startup processes are defined as a set of functionality that should be run once, at app startup.
///
/// The service is responsible for executing the processes and keeping track of the ones that need to be persiste. Persisted processes are conforming to `PersistableProcess`
/// To ensure the Persistable processes are persisted by the service, the Service itself must be persisted in your AppDelegate or SceneDelegate
///
/// Example:
///
/// ```
/// class AppDelegate
///  var startupProcessService = StartupProcessService()
///
///  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
///     startupProcessService
///         .execute(process: MyStartupProcess())
///
///     return true
///}
///  ...
/// ```
///
public final class StartupProcessService {
  public init() {}
  
  public var persistingProcesses = [StartupableProcess & PersistableProcess]()
  
  @discardableResult
  @available(*, deprecated, message: "Use `execute(process: StartupableProcess` instead with new process types.")
  public func execute(process: StartupProcess) -> StartupProcessService {
    process.run { _ in }
    return self
  }
  
  @discardableResult
  public func execute(process: StartupableProcess) -> StartupProcessService {
    process.run()
    if let process = process as? (StartupableProcess & PersistableProcess) {
      persistingProcesses.append(process)
    }
    return self
  }
}
