//
//  Validator.swift
//  PovioKit
//
//  Created by Toni Kocjan on 10/09/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Foundation

public enum Validators {
}

public extension Validators {
  static func nonEmptyValidator(
    _ value: String?,
    errorMessage: String
  ) -> ValidationStatus {
    value.isNilOrEmpty ? .invalid(errorMessage) : .valid
  }
}

public extension Validators {
  /// Adapt any validator into a `not-mandatory` validator.
  static func notMandatory<T, V: ValidationStatusConforming>(
    adapt validator: @escaping (T?) -> V,
    validValue: @escaping @autoclosure () -> V.Valid
  ) -> (T?) -> V {
    {
      if $0 == nil {
        return V.valid(validValue())
      }
      return validator($0)
    }
  }
  
  static func notMandatory<T, V: ValidationStatusConforming>(
    adapt validator: @escaping (T?) -> V,
    validValue: @escaping @autoclosure () -> V.Valid
  ) -> (T?) -> V where T: Collection {
    {
      if $0.isNilOrEmpty {
        return V.valid(validValue())
      }
      return validator($0)
    }
  }
  
  static func notMandatory<T, V: ValidationStatusConforming>(
    adapt validator: @escaping (T?) -> V
  ) -> (T?) -> V where V.Valid == () {
    notMandatory(adapt: validator, validValue: ())
  }
  
  static func notMandatory<T, V: ValidationStatusConforming>(
    adapt validator: @escaping (T?) -> V
  ) -> (T?) -> V where V.Valid == (), T: Collection {
    notMandatory(adapt: validator, validValue: ())
  }
}
