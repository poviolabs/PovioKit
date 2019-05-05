//
//  RestClientProtocol.swift
//  PovioKit
//
//  Created by Borut Tomažin on 14/01/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Alamofire

public protocol RestClientProtocol {
  typealias Headers = [String: String]
  typealias Params = [String: Any]
  typealias DataResult = ((Result<DataResponse, NetworkError>) -> Void)?
  
  func GET(endpoint: EndpointProtocol, parameters: Params?, headers: Headers?, _ result: DataResult)
  func GET<T: Decodable>(decode: T.Type, endpoint: EndpointProtocol, parameters: Params?, headers: Headers?, _ result: ((Result<T, NetworkError>) -> Void)?)
  func POST(endpoint: EndpointProtocol, parameters: Params?, headers: Headers?, _ result: DataResult)
  func POST<T: Decodable>(decode: T.Type, endpoint: EndpointProtocol, parameters: Params?, headers: Headers?, _ result: ((Result<T, NetworkError>) -> Void)?)
}
