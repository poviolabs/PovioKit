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
}

public protocol OAuthHeadersAdapter {
  func adapt(headers: inout HTTPHeaders)
}

open class OAuthRequestInterceptor {
  private let provider: OAuthProvider
  private let storage: OAuthStorage
  private let adapter: OAuthHeadersAdapter
  private let lock: NSLock = .init()
  
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
      Logger.debug("Request to `/\(request.request?.url?.lastPathComponent ?? "-")` failed with `401`! Will try to refresh access token.")
      storage.accessToken = nil
      updateAccessToken().observe {
        switch $0 {
        case .success:
          completion(.retry)
        case .failure(let error):
          completion(.doNotRetryWithError(error))
        }
      }
    case _:
      completion(.doNotRetryWithError(error))
    }
  }
}

private extension OAuthRequestInterceptor {
  func updateAccessToken() -> Promise<String> {
    lock.lock()
    return Promise(task)
  }
  
  func task(seal: Promise<String>) {
    switch storage.accessToken {
    case let token?:
      Logger.debug("Access token already fetched. Skip fetching ...!")
      seal.resolve(with: token)
      lock.unlock()
    case nil:
      Logger.debug("Fetching access token!")
      guard let refreshToken = storage.refreshToken else {
        Logger.debug("Refresh token is missing, we should logout user")
        seal.reject(with: AlamofireNetworkClient.Error.unauthorized)
        self.lock.unlock()
        return
      }
      provider
        .refresh(with: refreshToken)
        .observe { [weak self] in
          guard let self = self else { return }
          switch $0 {
          case .success(let response):
            Logger.debug("Refresh token success!!!")
            self.storage.accessToken = response.accessToken
            self.storage.refreshToken = response.refreshToken
            seal.resolve(with: response.accessToken)
            self.lock.unlock()
          case .failure(let error):
            Logger.debug("Refresh token failed with error \(error.localizedDescription), we should logout user")
            seal.reject(with: AlamofireNetworkClient.Error.unauthorized)
            self.lock.unlock()
          }
        }
    }
  }
}
