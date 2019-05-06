//
//  RestClient.swift
//  PovioKit
//
//  Created by Borut Tomažin on 14/01/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation
import Alamofire

public class RestClient<NetworkError: NetworkErrorProtocol>: RestClientProtocol {
  public typealias NetworkError = NetworkError
  
  private let manager: Alamofire.SessionManager
  private let retryCounter = RequestRetryCounter()
  private let jsonDecoder: JSONDecoder
  
  public init(jsonDecoder: JSONDecoder = .init()) {
    manager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
    self.jsonDecoder = jsonDecoder
  }
  
  /// GET rest api request
  public func GET(endpoint: EndpointProtocol,
                  parameters: RestClientProtocol.Params? = nil,
                  headers: RestClientProtocol.Headers? = nil,
                  _ result: ((Swift.Result<DataResponse, NetworkError>) -> Void)?) {
    request(endpoint: endpoint, method: .get, parameters: parameters, headers: headers, result)
  }
  
  /// GET rest api request
  public func GET<T: Decodable>(decode: T.Type,
                                endpoint: EndpointProtocol,
                                parameters: RestClientProtocol.Params? = nil,
                                headers: RestClientProtocol.Headers? = nil,
                                _ result: ((Swift.Result<T, NetworkError>) -> Void)?) {
    request(endpoint: endpoint, method: .get, parameters: parameters, headers: headers) {
      switch $0 {
      case .success(let response):
        DispatchQueue.global(qos: .background).async {
          do {
            let decodedObject = try self.jsonDecoder.decode(T.self, from: response.data)
            DispatchQueue.main.async { result?(.success(decodedObject)) }
          } catch {
            DispatchQueue.main.async { result?(.failure(NetworkError(wrap: error))) }
          }
        }
      case .failure(let error):
        DispatchQueue.main.async { result?(.failure(error)) }
      }
    }
  }
  
  /// POST rest api request
  public func POST(endpoint: EndpointProtocol,
                   parameters: RestClientProtocol.Params? = nil,
                   headers: RestClientProtocol.Headers? = nil,
                   _ result: ((Swift.Result<DataResponse, NetworkError>) -> Void)?) {
    request(endpoint: endpoint, method: .post, parameters: parameters, headers: headers, result)
  }
  
  /// POST rest api request
  public func POST<T: Decodable>(decode: T.Type,
                                 endpoint: EndpointProtocol,
                                 parameters: RestClientProtocol.Params?,
                                 headers: RestClientProtocol.Headers?,
                                 _ result: ((Swift.Result<T, NetworkError>) -> Void)?) {
    request(endpoint: endpoint, method: .post, parameters: parameters, headers: headers) {
      switch $0 {
      case .success(let response):
        DispatchQueue.global(qos: .background).async {
          do {
            let decodedObject = try self.jsonDecoder.decode(T.self, from: response.data)
            DispatchQueue.main.async { result?(.success(decodedObject)) }
          } catch {
            DispatchQueue.main.async { result?(.failure(NetworkError(wrap: error))) }
          }
        }
      case .failure(let error):
        DispatchQueue.main.async { result?(.failure(error)) }
      }
    }
  }
  
  public func PUT(endpoint: EndpointProtocol, parameters: RestClientProtocol.Params?, headers: RestClientProtocol.Headers?, _ result: ((Swift.Result<DataResponse, NetworkError>) -> Void)?) {
    
  }
  
  public func PUT<T: Decodable>(decode: T.Type, endpoint: EndpointProtocol, parameters: RestClientProtocol.Params?, headers: RestClientProtocol.Headers?, _ result: ((Swift.Result<T, NetworkError>) -> Void)?) {
    
  }
  
  public func DELETE(endpoint: EndpointProtocol, parameters: RestClientProtocol.Params?, headers: RestClientProtocol.Headers?, _ result: ((Swift.Result<DataResponse, NetworkError>) -> Void)?) {
    
  }
  
  public func DELETE<T: Decodable>(decode: T.Type, endpoint: EndpointProtocol, parameters: RestClientProtocol.Params?, headers: RestClientProtocol.Headers?, _ result: ((Swift.Result<T, NetworkError>) -> Void)?) {
    
  }
}

// MARK: - Private Methods
private extension RestClient {
  func request(endpoint: EndpointProtocol,
               method: HTTPMethod,
               parameters: RestClientProtocol.Params? = nil,
               headers: Headers? = nil,
               _ result: ((Swift.Result<DataResponse, NetworkError>) -> Void)?) {
    Logger.debug("\(method.rawValue) (started): " + endpoint.path, params: ["url": endpoint.url])
    let requestHeaders = combineRequestHeaders(customHeaders: headers)
    let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
    manager
      .request(endpoint.url, method: method, parameters: parameters, encoding: encoding, headers: requestHeaders)
      .validate(statusCode: 200..<300)
      .responseData { response in
        let statusCode = response.response?.statusCode ?? 0
        switch response.result {
        case .success(let data):
          Logger.debug("\(method.rawValue) (success): " + endpoint.path, params: ["status": statusCode, "url": endpoint.url])
          let dataResponse = DataResponse(statusCode: response.response?.statusCode ?? 0, data: data)
          self.retryCounter.clear(for: endpoint)
          result?(.success(dataResponse))
        case .failure(let error):
          Logger.debug("\(method.rawValue) (failure): " + endpoint.path, params: ["status": statusCode, "url": endpoint.url])
          switch self.retryCounter.shouldRetry(for: endpoint) {
          case true:
            let retryCount = self.retryCounter.retry(for: endpoint)
            Logger.debug("\(method.rawValue) (retry): " + endpoint.path, params: ["retryAttempt": retryCount, "url": endpoint.url])
            self.request(endpoint: endpoint, method: method, parameters: parameters, headers: headers, result)
          case false:
            self.retryCounter.clear(for: endpoint)
            result?(.failure(NetworkError(wrap: error)))
          }
        }
    }
  }
  
  func combineRequestHeaders(customHeaders: Headers?) -> Headers {
    var headers: Headers = Alamofire.SessionManager.defaultHTTPHeaders
    
    // custom headers
    if let customHeaders = customHeaders {
      for (key, value) in customHeaders {
        headers[key] = value
      }
    }
    
    return headers
  }
}
