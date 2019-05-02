//
//  Throttler.swift
//  PovioKit
//
//  Created by Domagoj Kulundzic on 1/05/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation

public class Throttler {
  private let queue: DispatchQueue
  private var job: DispatchWorkItem?
  public var delay: DispatchTimeInterval
  
  public init(queue: DispatchQueue = .main, delay: DispatchTimeInterval) {
    self.queue = queue
    self.delay = delay
  }
}

public extension Throttler {
  func execute(work: @escaping () -> Void) {
    cancelPendingJob()
    
    let newJob = DispatchWorkItem(block: work)
    job = newJob
    queue.asyncAfter(deadline: .now() + delay, execute: newJob)
  }
  
  func cancelPendingJob() {
    job?.cancel()
  }
}
