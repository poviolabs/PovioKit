//
//  Money.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 04/06/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation

public protocol Currency {
  var code: CurrencyCode { get }
  var symbol: String { get }
}

public extension Currency {
  var currencyCode: String {
    code.stringValue
  }
}

public enum CurrencyCode: Codable {
  /// U.S. Dollar (USD)
  case usd
  /// European Euro (EUR)
  case eur
  /// Canadian Dollar (CAD)
  case cad
  /// Chinese Yuan Renminbi (CNY)
  case cny
  /// Japanese Yen (JPY)
  case jpy
  /// British Pound (GBP)
  case gbp
  /// Swiss Franc (CHF)
  case chf
  
  var stringValue: String {
    switch self {
    case .usd:
      return "USD"
    case .eur:
      return "EUR"
    case .cad:
      return "CAD"
    case .cny:
      return "CNY"
    case .jpy:
      return "JPY"
    case .gbp:
      return "GBP"
    case .chf:
      return "CHF"
    }
  }
}

struct CurrencyGenerator {
  static func get(_ code: CurrencyCode) -> Currency {
    switch code {
    case .usd:
      return USD()
    case .eur:
      return EUR()
    case .cad:
      return CAD()
    case .cny:
      return CNY()
    case .jpy:
      return JPY()
    case .gbp:
      return GBP()
    case .chf:
      return CHF()
    }
  }
  
  private struct USD: Currency {
    var code = CurrencyCode.usd
    var symbol = "$"
  }
  
  private struct EUR: Currency {
    var code = CurrencyCode.eur
    var symbol = "€"
  }
  
  private struct CAD: Currency {
    var code = CurrencyCode.cad
    var symbol = "$"
  }
  
  private struct CNY: Currency {
    var code = CurrencyCode.cny
    var symbol = "¥"
  }
  
  private struct JPY: Currency {
    var code = CurrencyCode.jpy
    var symbol = "¥"
  }
  
  private struct GBP: Currency {
    var code = CurrencyCode.gbp
    var symbol = "£"
  }
  
  private struct CHF: Currency {
    var code = CurrencyCode.chf
    var symbol = "Fr"
  }
}
