//
//  DecodableDictionary+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomažin on 11/11/2020.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

/// Decodable dictionary that can be used in case where the structure of given value is unknown.
/// Based on https://github.com/levantAJ/AnyCodable
/// ```
/// struct MyResponse: Decodable {
///   let id: Int
///   let configuration: DecodableDictionary // dictionary with unknown key/value pairs
/// }
///
/// let configurationDictionary = myDeserializedResponse.configuration.dictionary // [String: Any]
/// ```
public struct DecodableDictionary: Decodable {
  public typealias Value = [String: Any]
  public let dictionary: Value?
  
  public init(from decoder: Decoder) throws {
    dictionary = try? decoder.container(keyedBy: AnyCodingKey.self).decode(Value.self)
  }
}

public extension KeyedDecodingContainer {
  func decode(_ type: [String: Any].Type) throws -> [String: Any] {
    var dictionary: [String: Any] = [:]
    for key in allKeys {
      if try decodeNil(forKey: key) {
        dictionary[key.stringValue] = NSNull()
      } else if let bool = try? decode(Bool.self, forKey: key) {
        dictionary[key.stringValue] = bool
      } else if let string = try? decode(String.self, forKey: key) {
        dictionary[key.stringValue] = string
      } else if let int = try? decode(Int.self, forKey: key) {
        dictionary[key.stringValue] = int
      } else if let double = try? decode(Double.self, forKey: key) {
        dictionary[key.stringValue] = double
      } else if let dict = try? decode([String: Any].self, forKey: key) {
        dictionary[key.stringValue] = dict
      } else if let array = try? decode([Any].self, forKey: key) {
        dictionary[key.stringValue] = array
      }
    }
    return dictionary
  }
  
  private func decode(_ type: [Any].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [Any] {
    var values = try nestedUnkeyedContainer(forKey: key)
    return try values.decode(type)
  }
  
  private func decode(_ type: [String: Any].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [String: Any] {
    try nestedContainer(keyedBy: AnyCodingKey.self, forKey: key).decode(type)
  }
}

public extension UnkeyedDecodingContainer {
  mutating func decode(_ type: [Any].Type) throws -> [Any] {
    var elements: [Any] = []
    while !isAtEnd {
      if try decodeNil() {
        elements.append(NSNull())
      } else if let int = try? decode(Int.self) {
        elements.append(int)
      } else if let bool = try? decode(Bool.self) {
        elements.append(bool)
      } else if let double = try? decode(Double.self) {
        elements.append(double)
      } else if let string = try? decode(String.self) {
        elements.append(string)
      } else if let values = try? nestedContainer(keyedBy: AnyCodingKey.self),
                let element = try? values.decode([String: Any].self) {
        elements.append(element)
      } else if var values = try? nestedUnkeyedContainer(),
                let element = try? values.decode([Any].self) {
        elements.append(element)
      }
    }
    return elements
  }
}

// MARK: - Private Model
private struct AnyCodingKey: CodingKey {
  let stringValue: String
  private (set) var intValue: Int?
  
  init?(stringValue: String) { self.stringValue = stringValue }
  init?(intValue: Int) {
    self.intValue = intValue
    stringValue = String(intValue)
  }
}
