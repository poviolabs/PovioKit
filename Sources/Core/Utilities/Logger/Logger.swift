//
//  Logger.swift
//  PovioKit
//
//  Created by Borut Tomažin on 04/29/2019.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import OSLog

public final class Logger {
  public typealias Parameters = [String: Any]
  public static let shared = Logger()
  public var logLevel: LogLevel = .none
  
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
    
    var label: String {
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
    flush(.debug, message: message, params: params, file: file, function: function, line: line)
  }
  
  /// Log info message
  static func info(_ message: String, params: Parameters? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    flush(.info, message: message, params: params, file: file, function: function, line: line)
  }
  
  /// Log warning message
  static func warning(_ message: String, params: Parameters? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    flush(.warn, message: message, params: params, file: file, function: function, line: line)
  }
  
  /// Log error message
  static func error(_ message: String, params: Parameters? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    flush(.error, message: message, params: params, file: file, function: function, line: line)
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
    let shortFileName = URL(string: file)?.lastPathComponent ?? ""
    var messagePrint = "\(level.label): \(message)"
    if let params = params, !params.isEmpty {
      messagePrint += ", params: \(params)"
    }
    
    if #available(iOS 14.0, *) {
      let category = "\(shortFileName) - \(function) - line \(line)"
      let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "--", category: category)
      switch level {
      case .none:
        break
      case .error:
        logger.error("\(messagePrint)")
      case .warn:
        logger.warning("\(messagePrint)")
      case .info:
        logger.info("\(messagePrint)")
      case .debug:
        logger.debug("\(messagePrint)")
      case .all:
        logger.log("\(messagePrint)")
      }
    } else {
      debugPrint(messagePrint)
      debugPrint()
    }
  }
}
