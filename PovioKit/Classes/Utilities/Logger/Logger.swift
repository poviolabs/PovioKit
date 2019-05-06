//
//  Logger.swift
//  PovioKit
//
//  Created by Borut Tomažin on 04/29/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation

public class Logger {
  public typealias Parameters = [String: Any]
  public static let shared = Logger()
  public var logLevel: LogLevel = .info
  
  private init() {}
}

// MARK: - Log Levels
public extension Logger {
  enum LogLevel: Int {
    case none = 0
    case error
    case warn
    case info
    case debug
    case all
    
    var string: String {
      switch self {
      case .info:
        return "INFO"
      case .warn:
        return "WARN"
      case .debug:
        return "DEBUG"
      case .error:
        return "ERROR"
      case .none, .all:
        return ""
      }
    }
  }
}

// MARK: - Public Methods
public extension Logger {
  /// Log debug message
  static func debug(_ message: String, params: Parameters? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    if shared.logLevel.rawValue >= LogLevel.debug.rawValue {
      flush(.debug, message: message, params: params, file: file, function: function, line: line)
    }
  }
  
  /// Log info message
  static func info(_ message: String, params: Parameters? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    if shared.logLevel.rawValue >= LogLevel.info.rawValue {
      flush(.info, message: message, params: params, file: file, function: function, line: line)
    }
  }
  
  /// Log warning message
  static func warning(_ message: String, params: Parameters? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    if shared.logLevel.rawValue >= LogLevel.warn.rawValue {
      flush(.warn, message: message, params: params, file: file, function: function, line: line)
    }
  }
  
  /// Log error message
  static func error(_ message: String, params: Parameters? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    if shared.logLevel.rawValue >= LogLevel.error.rawValue {
      flush(.error, message: message, params: params, file: file, function: function, line: line)
    }
  }
  
  /// Log crash
  static func crash(params: Parameters, file: String = #file, function: String = #function, line: Int = #line) {
    flush(.error, message: "app_crash", params: params, file: file, function: function, line: line)
  }
}

// MARK: - Private Methods
private extension Logger {
  static func flush(_ level: LogLevel, message: String, params: Parameters? = nil, file: String, function: String, line: Int) {
    guard shared.logLevel.rawValue >= level.rawValue else { return }
    
    let fileName = URL(fileURLWithPath: file).lastPathComponent.components(separatedBy: ".").first ?? ""
    var messagePrint = "\(level.string): \(fileName).\(function)[\(line)]: \(message)"
    if let params = params, !params.isEmpty {
      messagePrint += ", params: \(params)"
    }
    
    debugPrint(messagePrint)
    debugPrint()
  }
}
