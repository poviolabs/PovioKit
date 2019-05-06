//
//  RestClientProtocol.swift
//  PovioKit
//
//  Created by Borut Tomažin on 14/01/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Alamofire

public protocol NetworkErrorProtocol: Swift.Error {
  init(wrap error: Swift.Error)
}

public protocol RestClientProtocol {
  associatedtype NetworkError: NetworkErrorProtocol
  
  typealias Headers = [String: String]
  typealias Params = [String: Any]
  typealias DataResult = ((Swift.Result<DataResponse, NetworkError>) -> Void)?
  typealias GenericResult<T: Decodable> = ((Swift.Result<T, NetworkError>) -> Void)?
  
  func GET(endpoint: EndpointProtocol, parameters: Params?, headers: Headers?, _ result: DataResult)
  func GET<T: Decodable>(decode: T.Type, endpoint: EndpointProtocol, parameters: Params?, headers: Headers?, _ result: GenericResult<T>)
  func POST(endpoint: EndpointProtocol, parameters: Params?, headers: Headers?, _ result: DataResult)
  func POST<T: Decodable>(decode: T.Type, endpoint: EndpointProtocol, parameters: Params?, headers: Headers?, _ result: GenericResult<T>)
}
