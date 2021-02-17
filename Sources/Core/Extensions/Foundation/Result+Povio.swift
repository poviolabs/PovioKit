//
//  Result+Povio.swift
//  Alamofire
//
//  Created by Borut Tomažin on 24/02/2020.
//  Copyright © 2021 Povio Inc. All rights reserved.
//

import Foundation

public extension Result where Success == Void {
  /// Simplified `success` Result for Void types.
  static func success() -> Result {
    .success(())
  }
}