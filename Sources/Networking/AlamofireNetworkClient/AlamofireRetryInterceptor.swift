//
//  AlamofireRetryInterceptor.swift
//  PovioKit
//
//  Created by Borut Tomažin on 06/11/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Alamofire
import Foundation

public class AlamofireRetryInterceptor: RequestInterceptor {
  private let limit: Int
  private let delay: TimeInterval
  
  public init(limit: Int, delay: TimeInterval = 1) {
    self.limit = limit
    self.delay = delay
  }
  
  public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
    if request.retryCount < limit {
      completion(.retryWithDelay(delay))
    } else {
      completion(.doNotRetry)
    }
  }
}
