//
//  AlamofireRequestEngine.swift
//  PovioKit
//
//  Created by Toni Kocjan on 07/05/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Alamofire

public class AlamofireRequestEngine<Error: NetworkErrorProtocol>: RequestEngine {
  public typealias Headers = HTTPHeaders
  private let manager = SessionManager.default
  public init() {}
  
  public func request(endpoint: EndpointProtocol, method: HTTPMethod, parameters: [String : Any]?, headers: Headers?, _ result: ((Swift.Result<DataResponse, Error>) -> Void)?) {
    let requestHeaders = combineRequestHeaders(customHeaders: headers)
    let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
    manager
      .request(endpoint.path, method: Alamofire.HTTPMethod(rawValue: method.rawValue)!, parameters: parameters, encoding: encoding, headers: requestHeaders)
      .validate(statusCode: 200..<300)
      .responseData { response in
        let statusCode = response.response?.statusCode ?? 200
        switch response.result {
        case .success(let data):
          let dataResponse = DataResponse(statusCode: statusCode, data: data)
          result?(.success(dataResponse))
        case .failure(let error):
          result?(.failure(Error(error)))
        }
    }
  }
}

private extension AlamofireRequestEngine {
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
