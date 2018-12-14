//
//  Throttler.swift
//  PovioKit
//
//  Created by DK on 15/05/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import Foundation

public class Throttler {
	private let queue: DispatchQueue
	private var job: DispatchWorkItem?
	public var delay: TimeInterval
	
	public init(queue: DispatchQueue = .main, delay: TimeInterval = 0.5) {
		self.queue = queue
		self.delay = delay
	}
}

public extension Throttler {
	public func execute(work: @escaping () -> Void) {
		job?.cancel()
		let newJob = DispatchWorkItem(block: work)
		job = newJob
		queue.asyncAfter(deadline: .now() + delay, execute: newJob)
	}
	
	public func cancelPendingJob() {
		job?.cancel()
	}
}
