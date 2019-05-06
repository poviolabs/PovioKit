//
//  DispatchTimer.swift
//  PovioKit
//
//  Created by Borut Tomažin on 11/12/2018.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation

/// A NSTimer replacement using GCD.
public class DispatchTimer {
  private var timer: DispatchSourceTimer?
  
  public init() {}
  
  deinit {
    stop()
  }
}

// MARK: - Public Methods
public extension DispatchTimer {
  /// Creates and schedules repeating timer or one time execution afer given time interval
  func schedule(interval: DispatchTimeInterval, repeating: Bool, on queue: DispatchQueue, _ completion: (() -> Swift.Void)?) {
    timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
    switch repeating {
    case true:
      timer?.schedule(deadline: .now() + interval, repeating: interval)
    case false:
      timer?.schedule(deadline: .now() + interval, leeway: interval)
    }
    timer?.setEventHandler {
      if !repeating {
        self.stop()
      }
      completion?()
    }
    
    timer?.activate()
  }
  
  /// Creates and returns `DispatchTimer` object and schedules repeating timer or one time execution after given time interval
  static func scheduled(interval: DispatchTimeInterval, repeating: Bool, on queue: DispatchQueue, _ completion: (() -> Swift.Void)?) -> DispatchTimer {
    let timer = DispatchTimer()
    timer.schedule(interval: interval, repeating: repeating, on: queue, completion)
    return timer
  }
  
  /// Stops dispatch scheduler
  func stop() {
    timer?.cancel()
    timer = nil
  }
}
