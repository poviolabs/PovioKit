//
//  RequestRetryCounter.swift
//  PovioKit
//
//  Created by Borut Tomažin on 27/02/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation

class RequestRetryCounter {
  private var retries = [EndpointProtocol.Path: Int]()
}

extension RequestRetryCounter {
  func shouldRetry(for endpoint: EndpointProtocol) -> Bool {
    guard endpoint.retryCount > 0 else { return false }
    let existingRetryCount = retries[endpoint.path] ?? 0
    return existingRetryCount < endpoint.retryCount
  }
  
  func retry(for endpoint: EndpointProtocol) -> Int {
    let newCount = (retries[endpoint.path] ?? 0) + 1
    retries[endpoint.path] = newCount
    return newCount
  }
  
  func clear(for endpoint: EndpointProtocol) {
    retries.removeValue(forKey: endpoint.path)
  }
}
