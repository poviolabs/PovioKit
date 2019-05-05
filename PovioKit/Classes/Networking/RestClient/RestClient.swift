//
//  RestClient.swift
//  PovioKit
//
//  Created by Borut Tomažin on 14/01/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation
import Alamofire

public class RestClient {
  private let manager: Alamofire.SessionManager
  private let retryCounter = RequestRetryCounter()
  
  public init() {
    manager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
  }
}

// MARK: - Public Methods
public extension RestClient: RestClientProtocol {
  /// GET rest api request
  func GET(endpoint: EndpointProtocol,
           parameters: RestClientProtocol.Params? = nil,
           headers: RestClientProtocol.Headers? = nil,
           _ result: DataResult) {
    request(endpoint: endpoint, method: .get, parameters: parameters, headers: headers, result)
  }
  
  /// GET rest api request
  func GET<T: Decodable>(decode: T.Type,
                         endpoint: EndpointProtocol,
                         parameters: RestClientProtocol.Params? = nil,
                         headers: RestClientProtocol.Headers? = nil,
                         _ result: ((Result<T, NetworkError>) -> Void)?) {
    request(endpoint: endpoint, method: .get, parameters: parameters, headers: headers) {
      switch $0 {
      case .success(let response):
        DispatchQueue.global(qos: .background).async {
          do {
            let decodedObject = try JSONDecoder.default.decode(T.self, from: response.data)
            DispatchQueue.main.async { result?(.success(decodedObject)) }
          } catch {
            DispatchQueue.main.async { result?(.failure(.jsonDecode(error))) }
          }
        }
      case .failure(let error):
        DispatchQueue.main.async { result?(.failure(error)) }
      }
    }
  }
  
  /// POST rest api request
  func POST(endpoint: EndpointProtocol,
            parameters: RestClientProtocol.Params? = nil,
            headers: RestClientProtocol.Headers? = nil,
            _ result: RestClientProtocol.DataResult) {
    request(endpoint: endpoint, method: .post, parameters: parameters, headers: headers, result)
  }
  
  /// POST rest api request
  func POST<T: Decodable>(decode: T.Type,
                          endpoint: EndpointProtocol,
                          parameters: RestClientProtocol.Params?,
                          headers: RestClientProtocol.Headers?,
                          _ result: ((Result<T, NetworkError>) -> Void)?) {
    request(endpoint: endpoint, method: .post, parameters: parameters, headers: headers) {
      switch $0 {
      case .success(let response):
        DispatchQueue.global(qos: .background).async {
          do {
            let decodedObject = try JSONDecoder.default.decode(T.self, from: response.data)
            DispatchQueue.main.async { result?(.success(decodedObject)) }
          } catch {
            DispatchQueue.main.async { result?(.failure(.jsonDecode(error))) }
          }
        }
      case .failure(let error):
        DispatchQueue.main.async { result?(.failure(error)) }
      }
    }
  }
}

// MARK: - Private Methods
private extension RestClient {
  func request(endpoint: EndpointProtocol,
               method: HTTPMethod,
               parameters: RestClientProtocol.Params? = nil,
               headers: Headers? = nil,
               _ result: RestClientProtocol.DataResult) {
    updateToken { [weak self] token in
      guard let strongSelf = self else { return }
      Logger.debug("\(method.rawValue) (started): " + endpoint.path, params: ["url": endpoint.url])
      let requestHeaders = self?.combineRequestHeaders(customHeaders: headers, token: token)
      let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
      strongSelf.manager
        .request(endpoint.url, method: method, parameters: parameters, encoding: encoding, headers: requestHeaders)
        .validate(statusCode: 200..<300)
        .responseData { response in
          let statusCode = response.response?.statusCode ?? 0
          switch response.result {
          case .success(let data):
            Logger.debug("\(method.rawValue) (success): " + endpoint.path, params: ["status": statusCode, "url": endpoint.url])
            let dataResponse = DataResponse(statusCode: response.response?.statusCode ?? 0, data: data)
            strongSelf.retryCounter.clear(for: endpoint)
            result?(.success(dataResponse))
          case .failure(let error):
            Logger.debug("\(method.rawValue) (failure): " + endpoint.path, params: ["status": statusCode, "url": endpoint.url])
            switch strongSelf.retryCounter.shouldRetry(for: endpoint) {
            case true:
              let retryCount = strongSelf.retryCounter.retry(for: endpoint)
              Logger.debug("\(method.rawValue) (retry): " + endpoint.path, params: ["retryAttempt": retryCount, "url": endpoint.url])
              strongSelf.request(endpoint: endpoint, method: method, parameters: parameters, headers: headers, result)
            case false:
              strongSelf.retryCounter.clear(for: endpoint)
              result?(.failure(.generic(error)))
            }
          }
      }
    }
  }
  
  func updateToken(_ completion: ((_ token: String?) -> Void)?) {
    guard let currentUser = AccountManager.shared.user.entity?.firebaseUser else {
      completion?(nil)
      return
    }
    // this will retrieve token, if expired a refresh one is generated automatically
    currentUser.getIDToken { (idToken, _) in
      completion?(idToken)
    }
  }
  
  func combineRequestHeaders(customHeaders: Headers?, token: String?) -> Headers {
    var headers: Headers = Alamofire.SessionManager.defaultHTTPHeaders
    
    // authorization header
    if let token = token {
      headers["Authorization"] = "Bearer \(token)"
    } else {
      headers["Authorization"] = nil
    }
    
    // app specific headers
    headers["X-SKIP-APP-PLATFORM"] = "iOS"
    headers["X-SKIP-APP-NAME"] = "renter"
    headers["X-SKIP-APP-VERSION-STRING"] = UIDevice.appVersion
    
    // custom headers
    if let customHeaders = customHeaders {
      for (key, value) in customHeaders {
        headers[key] = value
      }
    }
    
    return headers
  }
}
