//
//  Money+Defaults.swift
//  PovioKit
//
//  Created by Toni K. Turk on 19/04/2022.
//  Copyright © 2024 Povio Labs. All rights reserved.
//

import Foundation

public extension Money {
  struct Defaults {
    public var precision = 2
    public var currency = Currency.usd
    public var locale = Locale.current
  }
}

// NOTE: - Not thread safe! Previous instances won't be affected.
public nonisolated(unsafe) var defaults = Money.Defaults()
