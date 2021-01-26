//
//  AlamofireNetworkClient.swift
//  PovioKit
//
//  Created by Toni Kocjan on 28/10/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Foundation
import Alamofire
import PovioKit

public typealias URLEncoding = Alamofire.URLEncoding
public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias HTTPHeaders = Alamofire.HTTPHeaders
public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias URLConvertible = Alamofire.URLConvertible
public typealias Parameters = [String: Any]
public typealias MultipartBuilder = (MultipartFormData) -> Void

public typealias Writer = (String) -> Void

open class AlamofireNetworkClient {
  private let session: Alamofire.Session
  
  public init(session: Alamofire.Session = .default) {
    self.session = session
  }
}

// MARK: - Rest API
public extension AlamofireNetworkClient {
  func request(
    method: HTTPMethod,
    endpoint: URLConvertible,
    headers: HTTPHeaders? = nil,
    interceptor: RequestInterceptor? = nil) -> Request
  {
    let request = session
      .request(endpoint,
               method: method,
               headers: headers,
               interceptor: interceptor)
    return .init(with: request)
  }
  
  func request(
    method: HTTPMethod,
    endpoint: URLConvertible,
    headers: HTTPHeaders? = nil,
    parameters: Parameters,
    parameterEncoding: ParameterEncoding,
    interceptor: RequestInterceptor? = nil) -> Request
  {
    let request = session
      .request(endpoint,
               method: method,
               parameters: parameters,
               encoding: parameterEncoding,
               headers: headers,
               interceptor: interceptor)
    return .init(with: request)
  }
  
  func request<E: Encodable>(
    method: HTTPMethod,
    endpoint: URLConvertible,
    headers: HTTPHeaders? = nil,
    encode: E,
    encoder: JSONEncoder = .init(),
    interceptor: RequestInterceptor? = nil) -> Request
  {
    let parameterEncoder: ParameterEncoder
    switch method {
    case .get, .delete, .head:
      parameterEncoder = URLEncodedFormParameterEncoder(encoder: encoder)
    default:
      parameterEncoder = JSONParameterEncoder(encoder: encoder)
    }
    
    let request = session
      .request(endpoint,
               method: method,
               parameters: encode,
               encoder: parameterEncoder,
               headers: headers,
               interceptor: interceptor)
    return .init(with: request)
  }
  
  func upload(
    method: HTTPMethod,
    endpoint: URLConvertible,
    data: Data,
    name: String,
    fileName: String,
    mimeType: String,
    parameters: Parameters? = nil,
    headers: HTTPHeaders? = nil,
    interceptor: RequestInterceptor? = nil) -> Request
  {
    let request = session
      .upload(multipartFormData: { builder in
        builder.append(data,
                       withName: name,
                       fileName: fileName,
                       mimeType: mimeType)
        parameters?
          .compactMap { key, value in (value as? String).map { (key, $0) } }
          .forEach { builder.append($0.0.data(using: .utf8)!, withName: $0.1) }
      },
      to: endpoint,
      method: method,
      headers: headers,
      interceptor: interceptor)
    return .init(with: request)
  }
  
  func upload(
    method: HTTPMethod,
    endpoint: URLConvertible,
    multipartFormBuilder: @escaping MultipartBuilder,
    headers: HTTPHeaders? = nil,
    interceptor: RequestInterceptor? = nil) -> Request
  {
    let request = session
      .upload(multipartFormData: multipartFormBuilder,
              to: endpoint,
              method: method,
              headers: headers,
              interceptor: interceptor)
    return .init(with: request)
  }
  
  func upload(
    method: HTTPMethod,
    fileURL: URL,
    endpoint: URLConvertible,
    headers: HTTPHeaders? = nil,
    interceptor: RequestInterceptor? = nil) -> Request
  {
    let request = session
      .upload(fileURL,
              to: endpoint,
              method: method,
              headers: headers,
              interceptor: interceptor,
              fileManager: .default)
    return .init(with: request)
  }
}

// MARK: - Models
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
    private var errorHandler: ((Data) throws -> Swift.Error)?
    
    init(with dataRequest: DataRequest) {
      self.dataRequest = dataRequest
    }
  }
}

// MARK: - Request API
public extension AlamofireNetworkClient.Request {
  var asJson: Promise<Any> {
    Promise { promise in
      dataRequest.responseJSON {
        switch $0.result {
        case .success(let json):
          promise.resolve(with: json)
        case .failure(let error):
          promise.reject(with: self.handleError(error))
        }
      }
    }
  }
  
  var asData: Promise<Data> {
    Promise { promise in
      dataRequest.responseData { (response: AFDataResponse<Data>) in
        switch response.result {
        case .success(let data):
          promise.resolve(with: data)
        case .failure(let error):
          promise.reject(with: self.handleError(error))
        }
      }
    }
  }
  
  var asVoid: Promise<()> {
    Promise { promise in
      dataRequest.response {
        switch $0.result {
        case .success:
          promise.resolve(with: ())
        case .failure(let error):
          promise.reject(with: self.handleError(error))
        }
      }
    }
  }
  
  func decode<D: Decodable>(_ decodable: D.Type, decoder: JSONDecoder = .init()) -> Promise<D> {
    Promise { promise in
      dataRequest.responseDecodable(decoder: decoder) { (response: AFDataResponse<D>) in
        switch response.result {
        case .success(let decodedObject):
          decoder.decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: <#T##Data#>)
          promise.resolve(with: decodedObject)
        case .failure(let error):
          promise.reject(with: self.handleError(error))
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
  
  func handleFailure(handler: @escaping (Data) throws -> Swift.Error) -> Self {
    self.errorHandler = handler
    return self
  }
}

// MARK: - Errors
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

// MARK: - Http Headers
public extension HTTPHeaders {
  static func authorization(bearer: String) -> Self {
    [.authorization(bearerToken: bearer)]
  }
  
  static func basic(basic: String) -> Self {
    ["Authorization": "Basic \(basic)"]
  }
}

// MARK: - Private Error Handling Methods
private extension AlamofireNetworkClient.Request {
  func handleError(_ error: Error) -> AlamofireNetworkClient.Error {
    guard let data = dataRequest.data, let handler = errorHandler else {
      switch error {
      case .responseSerializationFailed as AFError:
        return .other(error)
      case _ as AFError:
        return .request(.init(code: dataRequest.response?.statusCode ?? 0))
      case _:
        return .other(error)
      }
    }
    do {
      let handledError = try handler(data)
      return .other(handledError)
    } catch {
      return .other(error)
    }
  }
}

// MARK: - Private Status Code Handling
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
