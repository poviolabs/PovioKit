//
//  AlamofireNetworkClient.swift
//  PovioKit
//
//  Created by Toni Kocjan on 28/10/2019.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation
import Alamofire
import PovioKitCore
import PovioKitPromise

public typealias URLEncoding = Alamofire.URLEncoding
public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias HTTPHeaders = Alamofire.HTTPHeaders
public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias URLConvertible = Alamofire.URLConvertible
public typealias Parameters = [String: Any]
public typealias MultipartBuilder = (MultipartFormData) -> Void
public typealias ProgressHandler = Alamofire.Request.ProgressHandler
public typealias ErrorHandler = (Swift.Error, Data) throws -> Swift.Error

open class AlamofireNetworkClient {
  private let session: Alamofire.Session
  private let eventMonitors: [RequestMonitor]
  private let defaultErrorHandler: ErrorHandler?
  
  public init(
    session: Alamofire.Session = .default,
    eventMonitors: [RequestMonitor],
    defaultErrorHandler errorHandler: ErrorHandler? = nil
  ) {
    self.session = session
    self.eventMonitors = eventMonitors
    self.defaultErrorHandler = errorHandler
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
    return .init(with: request, eventMonitors: eventMonitors, defaultErrorHandler: defaultErrorHandler)
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
    return .init(with: request, eventMonitors: eventMonitors, defaultErrorHandler: defaultErrorHandler)
  }
  
  func request<E: Encodable>(
    method: HTTPMethod,
    endpoint: URLConvertible,
    headers: HTTPHeaders? = nil,
    encode: E,
    parameterEncoder: ParameterEncoder,
    interceptor: RequestInterceptor? = nil,
    uploadProgress: ProgressHandler? = nil,
    downloadProgress: ProgressHandler? = nil
  ) -> Request {
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
    return .init(with: request, eventMonitors: eventMonitors, defaultErrorHandler: defaultErrorHandler)
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
    return .init(with: request, eventMonitors: eventMonitors, defaultErrorHandler: defaultErrorHandler)
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
    return .init(with: request, eventMonitors: eventMonitors, defaultErrorHandler: defaultErrorHandler)
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
    return .init(with: request, eventMonitors: eventMonitors, defaultErrorHandler: defaultErrorHandler)
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
  enum Error: LocalizedError {
    case request(RequestError, ErrorInfo)
    case other(Swift.Error, ErrorInfo)
    
    public var errorDescription: String? {
      switch self {
      case .request(let err, _):
        return err.localizedDescription
      case .other(let err, _):
        return err.localizedDescription
      }
    }
  }
  
  class Request {
    private let dataRequest: DataRequest
    private var errorHandler: ErrorHandler?
    private let eventMonitors: [RequestMonitor]
    
    init(
      with dataRequest: DataRequest,
      eventMonitors: [RequestMonitor],
      defaultErrorHandler: ErrorHandler?
    ) {
      self.dataRequest = dataRequest
      self.eventMonitors = eventMonitors
      self.errorHandler = defaultErrorHandler
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
  var asData: Promise<Data> {
    asDataWithHeaders
      .map { $0.0 }
  }
  
  var asVoid: Promise<()> {
    asVoidWithHeaders
      .asVoid
  }
  
  func decode<D: Decodable>(
    _ decodable: D.Type,
    decoder: JSONDecoder = .init(),
    on dispatchQueue: DispatchQueue? = .main
  ) -> Promise<D> {
    decodeWithHeaders(decodable, decoder: decoder, on: dispatchQueue)
      .map { $0.0 }
  }
  
  var asDataWithHeaders: Promise<(Data, HTTPHeaders?)> {
    .init { promise in
      dataRequest.responseData { (response: AFDataResponse<Data>) in
        switch response.result {
        case .success(let data):
          self.eventMonitors.forEach { $0.requestDidSucceed(self) }
          promise.resolve(with: (data, response.response?.headers))
        case .failure(let error):
          let error = self.handleError(error)
          self.eventMonitors.forEach { $0.requestDidFail(self, with: error) }
          promise.reject(with: error)
        }
      }
    }
  }
  
  var asVoidWithHeaders: Promise<HTTPHeaders?> {
    .init { promise in
      dataRequest.response {
        switch $0.result {
        case .success:
          self.eventMonitors.forEach { $0.requestDidSucceed(self) }
          promise.resolve(with: $0.response?.headers)
        case .failure(let error):
          let error = self.handleError(error)
          self.eventMonitors.forEach { $0.requestDidFail(self, with: error) }
          promise.reject(with: error)
        }
      }
    }
  }
  
  func decodeWithHeaders<D: Decodable>(
    _ decodable: D.Type,
    decoder: JSONDecoder = .init(),
    on dispatchQueue: DispatchQueue? = .main
  ) -> Promise<(D, HTTPHeaders?)> {
    .init { promise in
      dataRequest.responseDecodable(decoder: decoder) { (response: AFDataResponse<D>) in
        switch response.result {
        case .success(let decodedObject):
          self.eventMonitors.forEach { $0.requestDidSucceed(self) }
          promise.resolve(with: (decodedObject, response.response?.headers), on: dispatchQueue)
        case .failure(let error):
          let error = self.handleError(error)
          self.eventMonitors.forEach { $0.requestDidFail(self, with: error) }
          promise.reject(with: error, on: dispatchQueue)
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
    guard let handler = errorHandler else {
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
      let handledError = try handler(error, dataRequest.data ?? .init())
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

/// # Domain model transformation:
///
/// A common pattern when dealing with remote APIs is to
/// transform the API response model to an app domain model.
/// 
/// The first approach one might try is to call `map` (or `compactMap`) on
/// the resulting promise:
/// 
///     client
///       .request(method: .get, endpoint: user-endpoint)
///       .validate()
///       .decode(UserResponse.self) // response model `UserResponse`
///       .compactMap { Mapper<User>.map($0) } // domain model `User`
/// 
/// However, the above implementation is suboptimal because the
/// transformation gets executed on the main thread, which can reduce
/// the efficiency of the app.
/// 
/// To solve this, we could give `compactMap` a different queue to execute 
/// the work on: 
/// 
///     ...
///       .compactMap(on: .global()) { Mapper<User>.map($0) }
///       
/// This solves the issue of doing the work on the main thread, but the resulting
/// promise executes its observers on the background queue as well - doing any UI
/// related work, without dispatching to main, would crash the app!
/// 
/// To solve both problems, we provide a small abstraction , which
/// dispatches the transformation work to a background thread, and returns a promise
/// which is resolved on the main thread.
/// 
/// Example:
/// 
///     extension UserResponse: DomainConvertible {
///       func toDomainModel() throws -> User? { ... }
///     }
///     client
///       .request(method: .get, endpoint: user-endpoint)
///       .validate()
///       .decode(UserResponse.self)
///       .mapToDomain()
///       

public protocol DomainConvertible: Decodable {
  associatedtype DomainModel
  func toDomainModel() throws -> DomainModel?
}

public extension Promise where Value: DomainConvertible {
  func mapToDomain<T>(
    transformOn: DispatchQueue = .global(),
    resolveOn: DispatchQueue = .main
  ) -> Promise<T> where T == Value.DomainModel {
    compactMap(on: transformOn) {
      try $0.toDomainModel()
    }
    .map(on: resolveOn) { $0 }
  }
}


public extension Promise where Value: Collection, Value.Element: DomainConvertible {
  func mapToDomain<T>(
    transformOn: DispatchQueue = .global(),
    resolveOn: DispatchQueue = .main
  ) -> Promise<[T]> where T == Value.Element.DomainModel {
    compactMap(on: transformOn) {
      try $0.compactMap { try $0.toDomainModel() }
    }
    .map(on: resolveOn) { $0 }
  }
}
