//
//  Validator.swift
//  PovioKit
//
//  Created by Toni Kocjan on 10/09/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Foundation

public func nonEmptyValidator<C: Collection>(errorMessage: String) -> (C?) -> DefaultValidationStatus {
  { $0.isNilOrEmpty ? .invalid(errorMessage) : .valid }
}

public func notMandatory<T, V: ValidationStatusConforming>(
  adapt validator: @escaping (T?) -> V,
  validValue: @escaping @autoclosure () -> V.Valid
) -> (T?) -> V {
  {
    if $0 == nil {
      return .valid(validValue())
    }
    return validator($0)
  }
}

public func notMandatory<T: Collection, V: ValidationStatusConforming>(
  adapt validator: @escaping (T?) -> V,
  validValue: @escaping @autoclosure () -> V.Valid
) -> (T?) -> V {
  {
    if $0.isNilOrEmpty {
      return .valid(validValue())
    }
    return validator($0)
  }
}

public func notMandatory<T, V: ValidationStatusConforming>(
  adapt validator: @escaping (T?) -> V
) -> (T?) -> V where V.Valid == () {
  notMandatory(adapt: validator, validValue: ())
}

public func notMandatory<T: Collection, V: ValidationStatusConforming>(
  adapt validator: @escaping (T?) -> V
) -> (T?) -> V where V.Valid == () {
  notMandatory(adapt: validator, validValue: ())
}
