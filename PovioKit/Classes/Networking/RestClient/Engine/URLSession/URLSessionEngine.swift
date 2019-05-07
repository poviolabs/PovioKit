//
//  URLSessionEngine.swift
//  PovioKit
//
//  Created by Toni Kocjan on 07/05/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation

public class URLSessionRequestEngine<Error: NetworkErrorProtocol>: RequestEngine {
  public func request(endpoint: EndpointProtocol, method: HTTPMethod, parameters: [String : Any]?, headers: [String : String]?, _ result: ((Result<DataResponse, Error>) -> Void)?) {
    guard let url = URL(string: endpoint.path) else {
      result?(.failure(Error(invalidUrl: endpoint.path)))
      return
    }
    let body: Data?
    if let parameters = parameters {
      guard let data = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
        result?(.failure(.encoding))
        return
      }
      body = data
    } else {
      body = nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.httpBody = body
    request.allHTTPHeaderFields = headers
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      switch (data, response, error) {
      case let (.some(data), .some(response), .none):
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200
        result?(.success(DataResponse(statusCode: statusCode, data: data)))
      case let (_, _, .some(error)):
        result?(.failure(Error(error)))
      default:
        break
      }
      }.resume()
  }
}
