//
//  OAuthRequestInterceptor.swift
//  PovioKit
//
//  Created by Toni Kocjan on 28/10/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Alamofire

public struct OAuthContainer {
  public let accessToken: String
  public let refreshToken: String
  
  public init(accessToken: String, refreshToken: String) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
}

public protocol OAuthStorage: AnyObject {
  var oauth: OAuthContainer? { get set }
}

public protocol OAuthProvider {
  func refresh(with refreshToken: String) -> Promise<OAuthContainer>
}

public protocol OAuthHeadersAdapter {
  func adapt(headers: inout HTTPHeaders)
}

open class OAuthRequestInterceptor {
  private let provider: OAuthProvider
  private let adapter: OAuthHeadersAdapter
  private let storage: OAuthStorage
  private let lock: NSLock = .init()
  
  public init(provider: OAuthProvider, adapter: OAuthHeadersAdapter, storage: OAuthStorage) {
    self.provider = provider
    self.adapter = adapter
    self.storage = storage
  }
}

// MARK: - RequestInterceptor
extension OAuthRequestInterceptor: RequestInterceptor {
  public func adapt(
    _ urlRequest: URLRequest,
    for session: Session,
    completion: @escaping (Result<URLRequest, Error>) -> Void)
  {
    var urlRequest = urlRequest
    adapter.adapt(headers: &urlRequest.headers)
    completion(.success(urlRequest))
  }
  
  public func retry(
    _ request: Request,
    for session: Session,
    dueTo error: Error,
    completion: @escaping (RetryResult) -> Void)
  {
    switch error.asAFError {
    case .responseValidationFailed(reason: .unacceptableStatusCode(code: 401)):
      lock.lock()
      
      guard let refreshToken = storage.oauth?.refreshToken else {
        completion(.doNotRetry)
        lock.unlock()
        return
      }
      
      Logger.debug("Request to `/\(request.request?.url?.lastPathComponent ?? "-")` failed with `401`! Will try to refresh access token.")
      storage.oauth = nil
      updateAccessToken(with: refreshToken).observe { [weak self] in
        guard let self = self else { return }
        switch $0 {
        case .success(let oauth):
          self.storage.oauth = oauth
          self.lock.unlock()
          completion(.retry)
        case .failure(let error):
          self.lock.unlock()
          completion(.doNotRetryWithError(error))
        }
      }
    case _:
      completion(.doNotRetryWithError(error))
    }
  }
}

private extension OAuthRequestInterceptor {
  func updateAccessToken(with refreshToken: String) -> Promise<OAuthContainer> {
    switch storage.oauth {
    case let oauth?:
      Logger.debug("Access token already fetched. Skip fetching ...!")
      return .value(oauth)
    case nil:
      Logger.debug("Fetching access token!")
      return provider.refresh(with: refreshToken)
    }
  }
}
