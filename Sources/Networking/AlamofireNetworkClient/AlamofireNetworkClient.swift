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
    eventMonitors: [RequestMonitor] = [],
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
  ) -> Request {
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
  
  func download<E: Encodable>(
    method: HTTPMethod,
    endpoint: URLConvertible,
    to destination: @escaping Alamofire.DownloadRequest.Destination,
    headers: HTTPHeaders? = nil,
    encode: E,
    parameterEncoder: ParameterEncoder,
    interceptor: RequestInterceptor? = nil,
    downloadProgress: ProgressHandler? = nil
  ) -> DownloadRequest {
    let request = session
      .download(
        endpoint,
        method: method,
        parameters: encode,
        encoder: parameterEncoder,
        headers: headers,
        interceptor: interceptor,
        to: destination
      )
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
      case let .request(err, info):
        return err.localizedDescription + "; " + info.description
      case let .other(err, info):
        return err.localizedDescription + "; " + info.description
      }
    }
  }
  
  class Request {
    private let dataRequest: Alamofire.DataRequest
    private var errorHandler: ErrorHandler?
    private let eventMonitors: [RequestMonitor]
    
    init(
      with dataRequest: Alamofire.DataRequest,
      eventMonitors: [RequestMonitor],
      defaultErrorHandler: ErrorHandler?
    ) {
      self.dataRequest = dataRequest
      self.eventMonitors = eventMonitors
      self.errorHandler = defaultErrorHandler
    }
  }
  
  class DownloadRequest {
    public let downloadRequest: Alamofire.DownloadRequest
    private var errorHandler: ErrorHandler?
    private let eventMonitors: [RequestMonitor]
    
    init(
      with downloadRequest: Alamofire.DownloadRequest,
      eventMonitors: [RequestMonitor],
      defaultErrorHandler: ErrorHandler?
    ) {
      self.downloadRequest = downloadRequest
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
  
  struct ErrorInfo: CustomStringConvertible {
    public var method: HTTPMethod?
    public var endpoint: URLConvertible?
    public var headers: HTTPHeaders?
    public var body: Data?
    public var response: Data?
    public var responseHTTPCode: Int?
    
    public var description: String {
      [
        method?.rawValue,
        try? endpoint?.asURL().absoluteString,
        headers?.description,
        response.flatMap { String(data: $0, encoding: .utf8) }
      ]
        .compactMap { $0 }
        .joined(separator: "\n")
    }
  }
  
  var info: ErrorInfo {
    switch self {
    case .request(_, let info),
        .other(_, let info):
      return info
    }
  }
}

// MARK: - Data Request API
public extension AlamofireNetworkClient.Request {
  var asData: Promise<Data> {
    asDataWithHeaders
      .map { $0.0 }
  }
  
  var asVoid: Promise<()> {
    asVoidWithHeaders
      .asVoid
  }
  
  var asString: Promise<String> {
    .init { promise in
      dataRequest.responseString {
        switch $0.result {
        case .success(let value):
          self.eventMonitors.forEach { $0.requestDidSucceed(self) }
          promise.resolve(with: value)
        case .failure(let error):
          let error = self.handleError(error)
          self.eventMonitors.forEach { $0.requestDidFail(self, with: error) }
          promise.reject(with: error)
        }
      }
    }
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

// MARK: - Download Request API
public extension AlamofireNetworkClient.DownloadRequest {
  var asURL: Promise<URL> {
    .init { promise in
      downloadRequest.response { response in
        switch response.result {
        case .success(let url):
          guard let url else {
            let error = AlamofireNetworkClient.Error.RequestError.other(0)
            promise.reject(with: error)
            return
          }
          promise.resolve(with: url)
        case .failure(let error):
          promise.reject(with: error)
        }
      }
    }
  }
  
  var asOptionalURL: Promise<URL?> {
    .init { promise in
      downloadRequest.response { response in
        switch response.result {
        case .success(let url):
          promise.resolve(with: url)
        case .failure(let error):
          promise.reject(with: error)
        }
      }
    }
  }
  
  func resume() -> Self {
    downloadRequest.resume()
    return self
  }
  
  func suspend() -> Self {
    downloadRequest.suspend()
    return self
  }
  
  func cancel() -> Self {
    downloadRequest.cancel()
    return self
  }
  
  func validate() -> Self {
    downloadRequest.validate()
    return self
  }
  
  func validate<S: Sequence>(statusCode: S) -> Self where S.Iterator.Element == Int {
    downloadRequest.validate(statusCode: statusCode)
    return self
  }
}

// MARK: - DataRequest async/await API
public extension AlamofireNetworkClient.Request {
  /// See Alamofire's documentation for details:
  ///
  /// ``Alamofire.Concurrency.serializingData``
  func data(
    automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
    dataPreprocessor: DataPreprocessor = DataResponseSerializer.defaultDataPreprocessor,
    emptyResponseCodes: Set<Int> = DataResponseSerializer.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = DataResponseSerializer.defaultEmptyRequestMethods
  ) async throws -> Data {
    do {
      let data = try await dataRequest.serializingData(
        automaticallyCancelling: shouldAutomaticallyCancel,
        dataPreprocessor: dataPreprocessor,
        emptyResponseCodes: emptyResponseCodes,
        emptyRequestMethods: emptyRequestMethods
      ).value
      eventMonitors.forEach { $0.requestDidSucceed(self) }
      return data
    } catch {
      let error = self.handleError(error)
      eventMonitors.forEach { $0.requestDidFail(self, with: error) }
      throw error
    }
  }
  
  var asDataAsync: Data {
    get async throws {
      try await data()
    }
  }
  
  var asVoidAsync: () {
    get async throws {
      try await _ = asDataAsync
    }
  }
  
  /// See Alamofire's documentation for details:
  ///
  /// ``Alamofire.Concurrency.serializingString``
  func string(
    automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
    dataPreprocessor: DataPreprocessor = StringResponseSerializer.defaultDataPreprocessor,
    encoding: String.Encoding? = nil,
    emptyResponseCodes: Set<Int> = StringResponseSerializer.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = StringResponseSerializer.defaultEmptyRequestMethods
  ) async throws -> String {
    do {
      let value = try await dataRequest.serializingString(
        automaticallyCancelling: shouldAutomaticallyCancel,
        dataPreprocessor: dataPreprocessor,
        encoding: encoding,
        emptyResponseCodes: emptyResponseCodes,
        emptyRequestMethods: emptyRequestMethods
      ).value
      eventMonitors.forEach { $0.requestDidSucceed(self) }
      return value
    } catch {
      let error = self.handleError(error)
      eventMonitors.forEach { $0.requestDidFail(self, with: error) }
      throw error
    }
  }
  
  var asStringAsync: String {
    get async throws {
      try await string()
    }
  }
  
  /// See Alamofire's documentation for details:
  ///
  /// ``Alamofire.Concurrency.serializingDecodable``
  func decode<D: Decodable>(
    _ decodable: D.Type,
    decoder: JSONDecoder = .init(),
    automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
    dataPreprocessor: DataPreprocessor = DecodableResponseSerializer<D>.defaultDataPreprocessor,
    emptyResponseCodes: Set<Int> = DecodableResponseSerializer<D>.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = DecodableResponseSerializer<D>.defaultEmptyRequestMethods
  ) async throws -> D {
    do {
      let value = try await dataRequest.serializingDecodable(
        D.self,
        automaticallyCancelling: shouldAutomaticallyCancel,
        dataPreprocessor: dataPreprocessor,
        decoder: decoder,
        emptyResponseCodes: emptyResponseCodes,
        emptyRequestMethods: emptyRequestMethods
      ).value
      eventMonitors.forEach { $0.requestDidSucceed(self) }
      return value
    } catch {
      let error = handleError(error)
      eventMonitors.forEach { $0.requestDidFail(self, with: error) }
      throw error
    }
  }
}

// MARK: - DataRequest async/await API
public extension AlamofireNetworkClient.DownloadRequest {
  var asURLAsync: URL {
    get async throws {
      try await asURL.asAsync
    }
  }
  
  var asOptionalURLAsync: URL? {
    get async throws {
      try await asOptionalURL.asAsync
    }
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
