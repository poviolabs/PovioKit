//
//  OAuthRequestInterceptor.swift
//  PovioKit
//
//  Created by Toni Kocjan on 28/10/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Foundation
import Alamofire
import PovioKit

public struct OAuthContainer {
  public let accessToken: String
  public let refreshToken: String
  
  public init(
    accessToken: String,
    refreshToken: String
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
}

public protocol OAuthStorage: AnyObject {
  var accessToken: String? { get set }
  var refreshToken: String? { get set }
}

public protocol OAuthProvider {
  func refresh(with refreshToken: String) -> Promise<OAuthContainer>
  func isAccessTokenValid() -> Bool
}

public extension OAuthProvider {
  func isAccessTokenValid() -> Bool { true }
}

public protocol OAuthHeadersAdapter {
  func adapt(headers: inout HTTPHeaders)
}

open class OAuthRequestInterceptor {
  private let provider: OAuthProvider
  private let storage: OAuthStorage
  private let adapter: OAuthHeadersAdapter
  private let lock: NSLock = .init()
  private var activeRequests: [Request: RequestState] = .init()
  
  public init(
    provider: OAuthProvider,
    storage: OAuthStorage,
    adapter: OAuthHeadersAdapter
  ) {
    self.provider = provider
    self.storage = storage
    self.adapter = adapter
  }
}

extension OAuthRequestInterceptor {
  enum RequestState {
    case retry
    case reject
  }
}

// MARK: - RequestInterceptor
extension OAuthRequestInterceptor: RequestInterceptor {
  public func adapt(
    _ urlRequest: URLRequest,
    for session: Session,
    completion: @escaping (Result<URLRequest, Error>) -> Void
  ) {
    var urlRequest = urlRequest
    adapter.adapt(headers: &urlRequest.headers)
    completion(.success(urlRequest))
  }
  
  public func retry(
    _ request: Request,
    for session: Session,
    dueTo error: Error,
    completion: @escaping (RetryResult) -> Void
  ) {
    switch error.asAFError {
    case .responseValidationFailed(reason: .unacceptableStatusCode(code: 401)):
      lock.lock()
      
      switch activeRequests[request] {
      case nil:
        activeRequests[request] = .retry
      case .retry:
        activeRequests[request] = .reject
      case .reject:
        activeRequests.removeValue(forKey: request)
        completion(.doNotRetryWithError(error))
        lock.unlock()
        return
      }
      
      Promise(task).observe {
        switch $0 {
        case .success:
          completion(.retry)
        case .failure(let error):
          completion(.doNotRetryWithError(error))
        }
        self.lock.unlock()
      }
    case _:
      completion(.doNotRetryWithError(error))
    }
  }
}

private extension OAuthRequestInterceptor {
  func task(seal: Promise<String>) {
    guard !provider.isAccessTokenValid() else {
      Logger.debug("No need to fetch access token as it is valid.")
      seal.resolve(with: self.storage.accessToken!)
      return
    }
    
    guard let refreshToken = storage.refreshToken else {
      Logger.debug("Refresh token is missing, we should logout user")
      seal.reject(with: AlamofireNetworkClient.Error.unauthorized)
      return
    }
    
    Logger.debug("Fetching access token!")
    provider
      .refresh(with: refreshToken)
      .observe {
        switch $0 {
        case .success(let response):
          Logger.debug("Refresh token success!")
          self.storage.accessToken = response.accessToken
          self.storage.refreshToken = response.refreshToken
          seal.resolve(with: response.accessToken)
        case .failure(let error):
          Logger.debug("Refresh token failed with error \(error.localizedDescription), we should logout user")
          seal.reject(with: AlamofireNetworkClient.Error.unauthorized)
        }
      }
  }
}
