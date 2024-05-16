//
//  ParameterEncoder+PovioKit.swift
//  PovioKit
//
//  Created by Egzon Arifi on 20/05/2022.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Alamofire
import Foundation

public extension ParameterEncoder where Self == URLEncodedFormParameterEncoder {
  static func urlEncoder(
    encoder: JSONEncoder = .init(),
    arrayEncoding: URLEncodedFormEncoder.ArrayEncoding = .noBrackets,
    boolEncoding: URLEncodedFormEncoder.BoolEncoding = .numeric
  ) -> URLEncodedFormParameterEncoder {
    .init(encoder: encoder, arrayEncoding: arrayEncoding, boolEncoding: boolEncoding)
  }
}

public extension ParameterEncoder where Self == JSONParameterEncoder {
  static func jsonEncoder(encoder: JSONEncoder = .init()) -> JSONParameterEncoder {
    .init(encoder: encoder)
  }
}
