//
//  AlamofireConsoleLogger.swift
//  PovioKit
//
//  Created by Borut Tomažin on 05/11/2020.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Alamofire
import Foundation
import PovioKit

public final class AlamofireConsoleLogger: EventMonitor {
  public let queue = DispatchQueue(label: "com.alamofire.console.networklogger")
  private let logger: (String) -> Void
  
  public init(logger: @escaping (String) -> Void = { Logger.debug($0) }) {
    self.logger = logger
  }
  
  public func request(_ request: Request, didCreateInitialURLRequest urlRequest: URLRequest) {
    logger("\(request.method) (start) to \(request.endpoint).")
  }
  
  public func requestDidFinish(_ request: Request) {
    logger("\(request.method) (success: \(request.statusCode)) to \(request.endpoint)")
  }
  
  public func request(_ request: Request, didFailTask task: URLSessionTask, earlyWithError error: AFError) {
    logger("\(request.method) (fail: \(request.statusCode)) to \(request.endpoint) due to: \(error.localizedDescription)")
  }
}

// MARK: - Private Getters
private extension Request {
  var method: String {
    request?.method?.rawValue ?? "<no method>"
  }
  
  var statusCode: Int {
    response?.statusCode ?? 0
  }
  
  var endpoint: String {
    request?.url?.path ?? "<no endpoint>"
  }
}
