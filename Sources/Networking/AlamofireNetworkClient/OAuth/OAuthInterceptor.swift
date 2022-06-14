//
//  OAuthRequestInterceptor.swift
//  PovioKit
//
//  Created by Toni Kocjan on 28/10/2019.
//  Copyright © 2021 Povio Inc. All rights reserved.
//

import Foundation
import Alamofire
import PovioKit
import PovioKitPromise

public protocol OAuthStorage: AnyObject {
  var oauthContainer: OAuthContainer? { get set }
}

public protocol OAuthProvider {
  func refresh(with refreshToken: String) -> Promise<OAuthContainer>
  func isAccessTokenValid() -> Bool
}

public protocol OAuthHeadersAdapter {
  func adapt(headers: inout HTTPHeaders)
}

open class OAuthRequestInterceptor {
  private let provider: OAuthProvider
  private let storage: OAuthStorage
  private let adapter: OAuthHeadersAdapter
  private let lock: NSLock = .init()
  private var activeRequests: [UUID: RequestState] = .init() /// @TODO: - Design a strategy to clear `activeRequests`
                                                             /// once in a while ...
  
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
      
      switch activeRequests[request.id] {
      case nil:
        activeRequests[request.id] = .retry
      case .retry:
        activeRequests[request.id] = .reject
      case .reject:
        activeRequests.removeValue(forKey: request.id)
        completion(.doNotRetryWithError(error))
        lock.unlock()
        return
      }
      
      Promise(task).finally {
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

// MARK: - Private Methods
private extension OAuthRequestInterceptor {
  func task(seal: Promise<String>) {
    guard let container = storage.oauthContainer else {
      Logger.debug("OAuth credentials are missing, we should logout user!")
      seal.reject(with: AlamofireNetworkClient.Error.unauthorized)
      return
    }
    
    guard !provider.isAccessTokenValid() else {
      Logger.debug("No need to fetch access token as it is valid.")
      seal.resolve(with: container.accessToken)
      return
    }
    
    Logger.debug("Fetching access token!")
    provider
      .refresh(with: container.refreshToken)
      .finally {
        switch $0 {
        case .success(let response):
          Logger.debug("Refresh token success!")
          self.storage.oauthContainer = response
          seal.resolve(with: response.accessToken)
        case .failure(let error):
          Logger.debug("Refresh token failed with error \(error.localizedDescription), we should logout user")
          seal.reject(with: AlamofireNetworkClient.Error.unauthorized)
        }
      }
  }
}
