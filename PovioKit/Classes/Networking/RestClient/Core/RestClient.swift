//
//  RestClient.swift
//  PovioKit
//
//  Created by Borut Tomažin on 14/01/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation

public protocol RequestEngine {
  associatedtype NetworkError: NetworkErrorProtocol
  
  func request(endpoint: EndpointProtocol,
               method: HTTPMethod,
               parameters: RestClientProtocol.Params?,
               headers: RestClientProtocol.Headers?,
               _ result: ((Swift.Result<DataResponse, NetworkError>) -> Void)?)
}

public class RestClient<Engine: RequestEngine>: RestClientProtocol {
  public typealias NetworkError = Engine.NetworkError
  
  private let retryCounter = RequestRetryCounter()
  let requestEngine: Engine
  let jsonDecoder: JSONDecoder
  
  public init(requestEngine: Engine, jsonDecoder: JSONDecoder = .init()) {
    self.requestEngine = requestEngine
    self.jsonDecoder = jsonDecoder
  }
}

public extension RestClient {
  func GET(endpoint: EndpointProtocol,
           parameters: RestClientProtocol.Params? = nil,
           headers: RestClientProtocol.Headers? = nil,
           _ result: ((Swift.Result<DataResponse, NetworkError>) -> Void)?) {
    requestEngine.request(endpoint: endpoint, method: .get, parameters: parameters, headers: headers, result)
  }
  
  func GET<T: Decodable>(decode: T.Type,
                         endpoint: EndpointProtocol,
                         parameters: RestClientProtocol.Params? = nil,
                         headers: RestClientProtocol.Headers? = nil,
                         _ result: ((Swift.Result<T, NetworkError>) -> Void)?) {
    requestEngine.request(endpoint: endpoint, method: .get, parameters: parameters, headers: headers) {
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
  
  func POST(endpoint: EndpointProtocol,
            parameters: RestClientProtocol.Params? = nil,
            headers: RestClientProtocol.Headers? = nil,
            _ result: ((Swift.Result<DataResponse, NetworkError>) -> Void)?) {
    requestEngine.request(endpoint: endpoint, method: .post, parameters: parameters, headers: headers, result)
  }
  
  func POST<T: Decodable>(decode: T.Type,
                          endpoint: EndpointProtocol,
                          parameters: RestClientProtocol.Params?,
                          headers: RestClientProtocol.Headers?,
                          _ result: ((Swift.Result<T, NetworkError>) -> Void)?) {
    requestEngine.request(endpoint: endpoint, method: .post, parameters: parameters, headers: headers) {
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
  
  func PUT(endpoint: EndpointProtocol, parameters: RestClientProtocol.Params?, headers: RestClientProtocol.Headers?, _ result: ((Swift.Result<DataResponse, NetworkError>) -> Void)?) {
    requestEngine.request(endpoint: endpoint, method: .put, parameters: parameters, headers: headers, result)
  }
  
  func PUT<T: Decodable>(decode: T.Type, endpoint: EndpointProtocol, parameters: RestClientProtocol.Params?, headers: RestClientProtocol.Headers?, _ result: ((Swift.Result<T, NetworkError>) -> Void)?) {
    requestEngine.request(endpoint: endpoint, method: .put, parameters: parameters, headers: headers) {
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
  
  func DELETE(endpoint: EndpointProtocol, parameters: RestClientProtocol.Params?, headers: RestClientProtocol.Headers?, _ result: ((Swift.Result<DataResponse, NetworkError>) -> Void)?) {
    requestEngine.request(endpoint: endpoint, method: .delete, parameters: parameters, headers: headers, result)
  }
  
  func DELETE<T: Decodable>(decode: T.Type, endpoint: EndpointProtocol, parameters: RestClientProtocol.Params?, headers: RestClientProtocol.Headers?, _ result: ((Swift.Result<T, NetworkError>) -> Void)?) {
    requestEngine.request(endpoint: endpoint, method: .delete, parameters: parameters, headers: headers) {
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
}
