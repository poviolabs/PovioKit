//
//  AlamofireRequestEngine.swift
//  PovioKit
//
//  Created by Toni Kocjan on 07/05/2019.
//

import Alamofire

public class AlamofireRequestEngine<NetworkError: NetworkErrorProtocol>: RequestEngine {
  public init() {}
  
  public func request(endpoint: EndpointProtocol, method: HTTPMethod, parameters: [String : Any]?, headers: [String : String]?, _ result: ((Result<DataResponse, NetworkError>) -> Void)?) {
    let requestHeaders = combineRequestHeaders(customHeaders: headers)
    let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
    strongSelf.manager
      .request(endpoint.url, method: method, parameters: parameters, encoding: encoding, headers: requestHeaders)
      .validate(statusCode: 200..<300)
      .responseData { response in
        let statusCode = response.response?.statusCode ?? 0
        switch response.result {
        case .success(let data):
          let dataResponse = DataResponse(statusCode: response.response?.statusCode ?? 0, data: data)
          self.retryCounter.clear(for: endpoint)
          result?(.success(dataResponse))
        case .failure(let error):
          result?(.failure(.generic(error)))
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
