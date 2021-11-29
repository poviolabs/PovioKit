//
//  AlamofireNetworkClient.swift
//  PovioKit
//
//  Created by Toni Kocjan on 28/10/2019.
//  Copyright © 2021 Povio Inc. All rights reserved.
//

import Foundation
import Alamofire
import PovioKit
import PovioKitPromise

public typealias URLEncoding = Alamofire.URLEncoding
public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias HTTPHeaders = Alamofire.HTTPHeaders
public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias URLConvertible = Alamofire.URLConvertible
public typealias Parameters = [String: Any]
public typealias MultipartBuilder = (MultipartFormData) -> Void
public typealias ProgressHandler = Alamofire.Request.ProgressHandler

open class AlamofireNetworkClient {
  private let session: Alamofire.Session
  private let eventMonitors: [RequestMonitor]
  
  public init(
    session: Alamofire.Session = .default,
    eventMonitors: [RequestMonitor]
  ) {
    self.session = session
    self.eventMonitors = eventMonitors
  }
}

// MARK: - Rest API
public extension AlamofireNetworkClient {
  func request(
    method: HTTPMethod,
    endpoint: URLConvertible,
    headers: HTTPHeaders? = nil,
    interceptor: RequestInterceptor? = nil,
    uploadProgress: ProgressHandler? = nil,
    downloadProgress: ProgressHandler? = nil
  ) -> Request {
    let request = session
      .request(
        endpoint,
        method: method,
        headers: headers,
        interceptor: interceptor)
    _ = uploadProgress.map { request.uploadProgress(closure: $0) }
    _ = downloadProgress.map { request.downloadProgress(closure: $0) }
    return .init(with: request, eventMonitors: eventMonitors)
  }
  
  func request(
    method: HTTPMethod,
    endpoint: URLConvertible,
    headers: HTTPHeaders? = nil,
    parameters: Parameters,
    parameterEncoding: ParameterEncoding,
    interceptor: RequestInterceptor? = nil,
    uploadProgress: ProgressHandler? = nil,
    downloadProgress: ProgressHandler? = nil
  ) -> Request {
    let request = session
      .request(
        endpoint,
        method: method,
        parameters: parameters,
        encoding: parameterEncoding,
        headers: headers,
        interceptor: interceptor)
    _ = uploadProgress.map { request.uploadProgress(closure: $0) }
    _ = downloadProgress.map { request.downloadProgress(closure: $0) }
    return .init(with: request, eventMonitors: eventMonitors)
  }
  
  func request<E: Encodable>(
    method: HTTPMethod,
    endpoint: URLConvertible,
    headers: HTTPHeaders? = nil,
    encode: E,
    encoder: JSONEncoder = .init(),
    interceptor: RequestInterceptor? = nil,
    uploadProgress: ProgressHandler? = nil,
    downloadProgress: ProgressHandler? = nil
  ) -> Request {
    let parameterEncoder: ParameterEncoder
    switch method {
    case .get, .delete, .head:
      parameterEncoder = URLEncodedFormParameterEncoder(encoder: encoder)
    default:
      parameterEncoder = JSONParameterEncoder(encoder: encoder)
    }
    
    let request = session
      .request(
        endpoint,
        method: method,
        parameters: encode,
        encoder: parameterEncoder,
        headers: headers,
        interceptor: interceptor)
    _ = uploadProgress.map { request.uploadProgress(closure: $0) }
    _ = downloadProgress.map { request.downloadProgress(closure: $0) }
    return .init(with: request, eventMonitors: eventMonitors)
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
    interceptor: RequestInterceptor? = nil,
    uploadProgress: ProgressHandler? = nil,
    downloadProgress: ProgressHandler? = nil
  ) -> Request {
    let request = session
      .upload(multipartFormData: { builder in
        builder.append(
          data,
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
    _ = uploadProgress.map { request.uploadProgress(closure: $0) }
    _ = downloadProgress.map { request.downloadProgress(closure: $0) }
    return .init(with: request, eventMonitors: eventMonitors)
  }
  
  func upload(
    method: HTTPMethod,
    endpoint: URLConvertible,
    multipartFormBuilder: @escaping MultipartBuilder,
    headers: HTTPHeaders? = nil,
    interceptor: RequestInterceptor? = nil,
    uploadProgress: ProgressHandler? = nil,
    downloadProgress: ProgressHandler? = nil
  ) -> Request {
    let request = session
      .upload(
        multipartFormData: multipartFormBuilder,
        to: endpoint,
        method: method,
        headers: headers,
        interceptor: interceptor)
    _ = uploadProgress.map { request.uploadProgress(closure: $0) }
    _ = downloadProgress.map { request.downloadProgress(closure: $0) }
    return .init(with: request, eventMonitors: eventMonitors)
  }
  
  func upload(
    method: HTTPMethod,
    fileURL: URL,
    endpoint: URLConvertible,
    headers: HTTPHeaders? = nil,
    interceptor: RequestInterceptor? = nil,
    uploadProgress: ProgressHandler? = nil,
    downloadProgress: ProgressHandler? = nil
  ) -> Request{
    let request = session
      .upload(
        fileURL,
        to: endpoint,
        method: method,
        headers: headers,
        interceptor: interceptor,
        fileManager: .default)
    _ = uploadProgress.map { request.uploadProgress(closure: $0) }
    _ = downloadProgress.map { request.downloadProgress(closure: $0) }
    return .init(with: request, eventMonitors: eventMonitors)
  }
  
  func cancelAllRequests(
    completingOnQueue queue: DispatchQueue,
    completion: (() -> Void)?
  ) {
    session.cancelAllRequests(
      completingOnQueue: queue,
      completion: completion
    )
  }
}

// MARK: - Models
public extension AlamofireNetworkClient {
  enum Error: Swift.Error {
    case request(RequestError, ErrorInfo)
    case other(Swift.Error, ErrorInfo)
  }
  
  class Request {
    private let dataRequest: DataRequest
    private var errorHandler: ((Swift.Error, Data) throws -> Swift.Error)?
    private let eventMonitors: [RequestMonitor]
    
    init(
      with dataRequest: DataRequest,
      eventMonitors: [RequestMonitor]
    ) {
      self.dataRequest = dataRequest
      self.eventMonitors = eventMonitors
    }
  }
}

public extension AlamofireNetworkClient.Error {
  enum RequestError: Swift.Error {
    case redirection(Int) // 300..<400
    case client(Int) // 400..<500
    case server(Int) // 500..<600
    case other(Int)
  }
  
  struct ErrorInfo {
    public var method: HTTPMethod?
    public var endpoint: URLConvertible?
    public var headers: HTTPHeaders?
    public var body: Data?
    public var response: Data?
    public var responseHTTPCode: Int?
  }
  
  var info: ErrorInfo {
    switch self {
    case .request(_, let info),
         .other(_, let info):
      return info
    }
  }
}

// MARK: - Request API
public extension AlamofireNetworkClient.Request {
  var asJson: Promise<Any> {
    .init { promise in
      dataRequest.responseJSON {
        switch $0.result {
        case .success(let json):
          self.eventMonitors.forEach { $0.requestDidSucceed(self) }
          promise.resolve(with: json)
        case .failure(let error):
          let error = self.handleError(error)
          self.eventMonitors.forEach { $0.requestDidFail(self, with: error) }
          promise.reject(with: error)
        }
      }
    }
  }
  
  var asData: Promise<Data> {
    .init { promise in
      dataRequest.responseData { (response: AFDataResponse<Data>) in
        switch response.result {
        case .success(let data):
          self.eventMonitors.forEach { $0.requestDidSucceed(self) }
          promise.resolve(with: data)
        case .failure(let error):
          let error = self.handleError(error)
          self.eventMonitors.forEach { $0.requestDidFail(self, with: error) }
          promise.reject(with: error)
        }
      }
    }
  }
  
  var asVoid: Promise<()> {
    .init { promise in
      dataRequest.response {
        switch $0.result {
        case .success:
          self.eventMonitors.forEach { $0.requestDidSucceed(self) }
          promise.resolve(with: ())
        case .failure(let error):
          let error = self.handleError(error)
          self.eventMonitors.forEach { $0.requestDidFail(self, with: error) }
          promise.reject(with: error)
        }
      }
    }
  }
  
  func decode<D: Decodable>(_ decodable: D.Type, decoder: JSONDecoder = .init()) -> Promise<D> {
    .init { promise in
      dataRequest.responseDecodable(decoder: decoder) { (response: AFDataResponse<D>) in
        switch response.result {
        case .success(let decodedObject):
          self.eventMonitors.forEach { $0.requestDidSucceed(self) }
          promise.resolve(with: decodedObject)
        case .failure(let error):
          let error = self.handleError(error)
          self.eventMonitors.forEach { $0.requestDidFail(self, with: error) }
          promise.reject(with: error)
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
  
  func handleFailure(handler: @escaping (Swift.Error, Data) throws -> Swift.Error) -> Self {
    self.errorHandler = handler
    return self
  }
}

// MARK: - Errors
public extension AlamofireNetworkClient.Error {
  static var unauthorized: AlamofireNetworkClient.Error {
    .request(.client(401), .init())
  }
  
  static var badRequest: AlamofireNetworkClient.Error {
    .request(.client(400), .init())
  }
  
  static var internalServerError: AlamofireNetworkClient.Error {
    .request(.server(500), .init())
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
        return .other(error, errorInfo)
      case _ as AFError:
        return .request(.init(code: dataRequest.response?.statusCode ?? 0), errorInfo)
      case _:
        return .other(error, errorInfo)
      }
    }
    do {
      let handledError = try handler(error, data)
      return .other(handledError, errorInfo)
    } catch {
      return .other(error, errorInfo)
    }
  }
  
  var errorInfo: AlamofireNetworkClient.Error.ErrorInfo {
    .init(
      method: dataRequest.request?.method,
      endpoint: dataRequest.request?.url,
      headers: dataRequest.request?.headers,
      body: dataRequest.request?.httpBody,
      response: dataRequest.data,
      responseHTTPCode: dataRequest.response?.statusCode
    )
  }
}

// MARK: - Private Status Code Handling
private extension AlamofireNetworkClient.Error.RequestError {
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

public protocol RequestMonitor: AnyObject {
  func requestDidSucceed(_ request: AlamofireNetworkClient.Request)
  func requestDidFail(_ request: AlamofireNetworkClient.Request, with error: AlamofireNetworkClient.Error)
}

public extension RequestMonitor {
  func requestDidSucceed(_ request: AlamofireNetworkClient.Request) {}
  func requestDidFail(_ request: AlamofireNetworkClient.Request, with error: AlamofireNetworkClient.Error) {}
}
