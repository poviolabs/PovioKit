//
//  AlamofireNetworkClient.swift
//  PovioKit
//
//  Created by Toni Kocjan on 28/10/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Alamofire

public typealias URLEncoding = Alamofire.URLEncoding
public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias HTTPHeaders = Alamofire.HTTPHeaders
public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias URLConvertible = Alamofire.URLConvertible
public typealias Parameters = [String: Any]

public typealias Writer = (String) -> Void

open class AlamofireNetworkClient {
  private let session: Alamofire.Session
  private let logger: Writer
  
  public init(session: Alamofire.Session = .default, logger: @escaping Writer = { PovioKit.Logger.debug($0) }) {
    self.session = session
    self.logger = logger
  }
}

// MARK: - Rest API
public extension AlamofireNetworkClient {
  func request(
    method: HTTPMethod,
    endpoint: URLConvertible,
    headers: HTTPHeaders? = nil) -> Request
  {
    logger("Starting \(method.rawValue) request to \(endpoint)!")
    let request = session
      .request(endpoint,
               method: method,
               headers: headers)
    return .init(dataRequest: request, logger: logger)
  }
  
  func request(
    method: HTTPMethod,
    endpoint: URLConvertible,
    headers: HTTPHeaders? = nil,
    parameters: Parameters,
    parameterEncoding: ParameterEncoding) -> Request
  {
    logger("Starting \(method.rawValue) request to \(endpoint)!")
    let request = session
      .request(endpoint,
               method: method,
               parameters: parameters,
               encoding: parameterEncoding,
               headers: headers)
    return .init(dataRequest: request, logger: logger)
  }
  
  func request<E: Encodable>(
    method: HTTPMethod,
    endpoint: URLConvertible,
    headers: HTTPHeaders? = nil,
    encode: E,
    encoderConfigurator configurator: ((JSONEncoder) -> Void)? = nil) -> Request
  {
    logger("Starting \(method.rawValue) request to \(endpoint)!")
    let encoder = JSONEncoder()
    configurator?(encoder)
    let request = session
      .request(endpoint,
               method: method,
               parameters: encode,
               encoder: JSONParameterEncoder(encoder: encoder),
               headers: headers)
    return .init(dataRequest: request, logger: logger)
  }
  
  func upload(
    method: HTTPMethod,
    endpoint: URLConvertible,
    data: Data,
    name: String,
    fileName: String,
    mimeType: String,
    parameters: Parameters? = nil,
    headers: HTTPHeaders? = nil) -> Request
  {
    logger("Starting \(method.rawValue) request to \(endpoint)!")
    let request = session
      .upload(multipartFormData: { $0.append(data,
                                             withName: name,
                                             fileName: fileName,
                                             mimeType: mimeType) },
              to: endpoint,
              method: method,
              headers: headers)
    return .init(dataRequest: request, logger: logger)
  }
}

public extension AlamofireNetworkClient {
  enum RequestError: Swift.Error {
    case redirection(Int) // 300..<400
    case client(Int) // 400..<500
    case server(Int) // 500..<600
    case other(Int)
  }
  
  enum Error: Swift.Error {
    case request(RequestError)
    case other(Swift.Error)
  }
  
  class Request {
    private let dataRequest: DataRequest
    private let logger: Writer
    
    init(dataRequest: DataRequest, logger: @escaping Writer) {
      self.dataRequest = dataRequest
      self.logger = logger
    }
  }
}

// MARK: - Request API
public extension AlamofireNetworkClient.Request {
  func json() -> Promise<Any> {
    Promise { promise in
      dataRequest.responseJSON {
        switch $0.result {
        case .success(let json):
          self.logger("Request succeded with JSON!")
          promise.resolve(with: json)
        case .failure(let error):
          promise.reject(with: self.handleError(error, code: $0.response?.statusCode))
        }
      }
    }
  }
  
  func decode<D: Decodable>(
    _ decodable: D.Type,
    decoder: JSONDecoder) -> Promise<D>
  {
    Promise { promise in
      dataRequest.responseDecodable(decoder: decoder) { (response: AFDataResponse<D>) in
        switch response.result {
        case .success(let decodedObject):
          self.logger("Request succededed with \(type(of: decodedObject))!")
          promise.resolve(with: decodedObject)
        case .failure(let error):
          promise.reject(with: self.handleError(error, code: response.response?.statusCode))
        }
      }
    }
  }
  
  func data() -> Promise<Data> {
    Promise { promise in
      dataRequest.responseData {
        switch $0.result {
        case .success(let data):
          self.logger("Request succededed with Data!")
          promise.resolve(with: data)
        case .failure(let error):
          promise.reject(with: self.handleError(error, code: $0.response?.statusCode))
        }
      }
    }
  }
  
  var asVoid: Promise<()> {
    Promise { promise in
      dataRequest.response {
        switch $0.result {
        case .success:
          self.logger("Request succededed with ())!")
          promise.resolve(with: ())
        case .failure(let error):
          promise.reject(with: self.handleError(error, code: $0.response?.statusCode))
        }
      }
    }
  }
  
  func resume() -> Self {
    dataRequest.resume()
    return self
  }
  
  func suspend() -> Self {
    dataRequest.suspend()
    return self
  }
  
  func cancel() -> Self {
    dataRequest.cancel()
    return self
  }
  
  func validate() -> Self {
    dataRequest.validate()
    return self
  }
  
  func validate<S: Sequence>(statusCode: S) -> Self where S.Iterator.Element == Int {
    dataRequest.validate(statusCode: statusCode)
    return self
  }
}

public extension AlamofireNetworkClient.Error {
  static var unauthorized: AlamofireNetworkClient.Error {
    .request(.client(401))
  }
  
  static var badRequest: AlamofireNetworkClient.Error {
    .request(.client(400))
  }
  
  static var internalServerError: AlamofireNetworkClient.Error {
    .request(.server(500))
  }
}

private extension AlamofireNetworkClient.Request {
  func handleError(_ error: Error, code: Int?) -> AlamofireNetworkClient.Error {
    switch error {
    case .responseSerializationFailed as AFError:
      logger("Request failed with status code \(code ?? 0) due to serialization error: \(error.localizedDescription)")
      return .other(error)
    case _ as AFError:
      logger("Request failed with status code \(code ?? 0) due to: \(error.localizedDescription)")
      return .request(.init(code: code ?? 0))
    case _:
      logger("Request failed with status code \(code ?? 0) due to: \(error.localizedDescription)")
      return .other(error)
    }
  }
}

private extension AlamofireNetworkClient.RequestError {
  init(code: Int) {
    switch code {
    case 300..<400:
      self = .redirection(code)
    case 400..<500:
      self = .client(code)
    case 500..<600:
      self = .server(code)
    case _:
      self = .other(code)
    }
  }
}

public extension HTTPHeaders {
  static func authorization(bearer: String) -> Self {
    ["Authorization": "Bearer \(bearer)"]
  }
  
  static func basic(basic: String) -> Self {
    ["Authorization": "Basic \(basic)"]
  }
}
