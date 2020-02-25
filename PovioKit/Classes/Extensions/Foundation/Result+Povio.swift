//
//  Result+Povio.swift
//  Alamofire
//
//  Created by Borut Tomažin on 24/02/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//
import Foundation

extension Result where Success == Void {
  /// Simplified `success` result for Void types.
  static func success() -> Result {
    .success(())
  }
}
