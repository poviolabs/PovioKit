//
//  URLEncodedFormParameterEncoder+Skip.swift
//  PovioKit
//
//  Created by Borut Tomažin on 04/11/2020.
//  Copyright © 2020 PovioLabs. All rights reserved.
//

import Alamofire
import Foundation

public extension URLEncodedFormParameterEncoder {
  convenience init(encoder: JSONEncoder) {
    let formEncoder = URLEncodedFormEncoder(alphabetizeKeyValuePairs: true,
                                            arrayEncoding: .brackets,
                                            boolEncoding: .numeric,
                                            dataEncoding: Self.dataEncoding(from: encoder.dataEncodingStrategy),
                                            dateEncoding: Self.dateEncoding(from: encoder.dateEncodingStrategy),
                                            keyEncoding: Self.keyEncoding(from: encoder.keyEncodingStrategy),
                                            spaceEncoding: .percentEscaped,
                                            allowedCharacters: .afURLQueryAllowed)
    self.init(encoder: formEncoder, destination: .methodDependent)
  }
}

private extension URLEncodedFormParameterEncoder {
  static func dateEncoding(from strategy: JSONEncoder.DateEncodingStrategy) -> URLEncodedFormEncoder.DateEncoding {
    switch strategy {
    case .deferredToDate:
      return .deferredToDate
    case .secondsSince1970:
      return .secondsSince1970
    case .millisecondsSince1970:
      return .millisecondsSince1970
    case .iso8601:
      return .iso8601
    case .formatted(let formatter):
      return .formatted(formatter)
    case .custom:
      Logger.warning("Custom date encoding is not handled.")
      return .deferredToDate
    @unknown default:
      return .deferredToDate
    }
  }
  
  static func keyEncoding(from strategy: JSONEncoder.KeyEncodingStrategy) -> URLEncodedFormEncoder.KeyEncoding {
    switch strategy {
    case .useDefaultKeys:
      return .useDefaultKeys
    case .convertToSnakeCase:
      return .convertToSnakeCase
    case .custom:
      Logger.warning("Custom key encoding is not handled.")
      return .useDefaultKeys
    @unknown default:
      return .useDefaultKeys
    }
  }
  
  static func dataEncoding(from strategy: JSONEncoder.DataEncodingStrategy) -> URLEncodedFormEncoder.DataEncoding {
    switch strategy {
    case .deferredToData:
      return .deferredToData
    case .base64:
      return .base64
    case .custom:
      Logger.warning("Custom data encoding is not handled.")
      return .base64
    @unknown default:
      return .base64
    }
  }
}
