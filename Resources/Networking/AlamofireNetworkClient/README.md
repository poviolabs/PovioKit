# Alamofire Network Client

High-level network client abstraction based on [Alamofire](https://github.com/Alamofire/Alamofire).


## Examples

#### Retreiving JSON object from an endpoint

```swift
let client = AlamofireNetworkClient()
let json = client
  .request(method: .get, 
           endpoint: "http://my-amazing-api.com/endpoint")
  .validate() // makes sure status code is in 200..<300
  .asJson // parse `JSON` from the response
```

#### Serialize the response into a data model

```swift
let client = AlamofireNetworkClient()
let model = client
  .request(method: .get, 
           endpoint: "http://my-amazing-api.com/endpoint")
  .validate() // makes sure status code is in 200..<300
  .decode(MyModelResponse.self) // parse `MyModelResponse` from the response
```

#### The `request` method returns a `AlamofireNetworkClient.Request` object, on which we can perform other operations as well

- pause / resume / cancel request:

```swift
let client = AlamofireNetworkClient()
let request = client
  .request(method: .get, 
           endpoint: "http://my-amazing-api.com/endpoint")
  .validate() // makes sure status code is in 200..<300
...
request.suspend()
...
request.resume()
...
request.cancel()
```

- custom validation:

```swift
let client = AlamofireNetworkClient()
let request = client
  .request(method: .get, 
           endpoint: "http://my-amazing-api.com/endpoint")
  .validate(statusCode: [200]) // only `200` is acceptable status code
```

- parsing:

#### Aside from `JSON` and `Decodable` parsing, `AlamofireNetworkClient.Request` also enables us to also parse `Data` and `()`

```swift
let client = AlamofireNetworkClient()
let request = client
  .request(method: .get, 
           endpoint: "http://my-amazing-api.com/endpoint")

let data = request.asData // parse `Data`
```

#### Sometimes we want to configure the way objects are decoded. We do that by providing a custom decoder instance `request` method

```swift
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .formatted(CustomDateFormatter())
decoder.keyDecodingStrategy = .convertFromSnakeCase

let client = AlamofireNetworkClient()
let model = client
  .request(method: .get, 
           endpoint: "http://my-amazing-api.com/endpoint",
           decoderConfigurator: configurator)
  .validate() // makes sure status code is in 200..<300
  .decode(MyModel.self, decoder: decoder) // parse `MyModel` from the response, with custom `decoder`
```

#### Sending data to the server is also a common task, which is very easy to do to using `AlamofireNetworkClient`. We have two options

- Sending a `JSON` object:
 
```swift
let params = ["latitude": 0, "longitude": 0]
let client = AlamofireNetworkClient()
client
  .request(method: .post, 
           endpoint: "http://my-amazing-api.com/endpoint",
           parameters: params)
```
 
 or
 
- Sending a data model object directly:

```swift
struct Model: Encodable {
  let latitude: Double
  let longitude: Double
}

let object = Model(latitude: 0, longitude: 0)
let client = AlamofireNetworkClient()
client
  .request(method: .post, 
           endpoint: "http://my-amazing-api.com/endpoint",
           encode: object)
```

#### Similarily as configuring decoder, we can also provide an encoder custom encoding

```swift
struct Model: Encodable {
  let latitude: Double
  let longitude: Double
}

let encoder = JSONEncoder()
encoder.keyEncodingStrategy = .convertToSnakeCase

let object = Model(latitude: 0, longitude: 0)
let client = AlamofireNetworkClient()
client
  .request(method: .post, 
           endpoint: "http://my-amazing-api.com/endpoint",
           encode: object,
           encoder: encoder)
```

#### The client also provides abitility to define interceptors. Either session or request based

- Session based interceptor:

```swift
extension AlamofireNetworkClient {
  static var custom: AlamofireNetworkClient {
    let session: Session = {
      let configuration = URLSessionConfiguration.af.default
      configuration.timeoutIntervalForRequest = 60
      configuration.waitsForConnectivity = true
      return Session(configuration: configuration,
                     interceptor: CustomInterceptor()])
    }()
    
    return .init(session: session)
  }
}
```

- Reuqest based interceptor:

```swift
let client = AlamofireNetworkClient()
client
  .request(method: .post, 
           endpoint: "http://my-amazing-api.com/endpoint",
           encode: object,
           interceptor: AlamofireRetryInterceptor(limit: 2))
```

This is also an example on how to define a request retry policy. In this case, request will be retried 2 times on any error.

#### Console logging interceptor
```swift
extension AlamofireNetworkClient {
  static var custom: AlamofireNetworkClient {
    let session: Session = {
      .init(configuration: URLSessionConfiguration.af.default,
            eventMonitors: [AlamofireConsoleLogger()])
    }()
    
    return .init(session: session)
  }
}
```

By doing that we'll see logs in the console for each request start, success and failure.

## OAuth

Properly handling OAuth is a challenging task that needs special attention in order to make user re/authorization as seamless as possible. Up until recently, we have been using internal `OAuthRequestInterceptor`, which has its flaws. Therefore, we needed a better solution. Fortunately, Alamofire released its own [solution](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#authenticationinterceptor) to handle locking and threading issues in version [5.2](https://github.com/Alamofire/Alamofire/releases/tag/5.2.0).

In order to implement this into your app, create a class and conform to `Authenticator` protocol.

```swift
class OAuthAuthenticator: Authenticator {
  func apply(_ credential: OAuthCredential, to urlRequest: inout URLRequest) {
    // add request header with token info
  }

  func refresh(_ credential: OAuthCredential,
               for session: Session,
               completion: @escaping (Result<OAuthCredential, Error>) -> Void) {
    // request new token and return it in `completion`
  }

  func didRequest(_ urlRequest: URLRequest,
                  with response: HTTPURLResponse,
                  failDueToAuthenticationError error: Error) -> Bool {
    false // depends on the server implementation
  }

  func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: OAuthCredential) -> Bool {
    true // depends on the server implementation
  }
}
```

Create interceptor and attach it to a session.
```swift
let interceptor = AuthenticationInterceptor(authenticator: OAuthAuthenticator())
let session = Session(interceptor: interceptor)
```

## Error handling

`AlamofireNetworkClient` is designed so that error handling would be as intuitive as possible. `AlamofireNetworkClient.Error` type has two cases - it's either a `request` error or some other error (wrapping the underlying error).

Request error is directly linked to the HTTP status code of the response. It's defined as follows:
 
- 300 ..< 400: `redirect` error
- 400 ..< 500: `client` error (bad request)
- 500 ..< 600: `server` error (internal server error)
- any other status code: `other`

This design makes it easy for the user to handle special cases very naturally:

```swift
let parameters = ["type": "forgot_password",
                  "email": email]
let client = AlamofireNetworkClient()
  restClient
    .request(method: .post,
             endpoint: Endpoint.Auth.forgotPassword,
             headers: .basic,
             parameters: parameters,
             parameterEncoding: JSONEncoding.default)
    .validate()
    .observe {
        switch $0 {
        case .success:
          completion(.success(()))
        case .failure(.request(.client(400))): // handle 400 - bad request
          completion(.failure(.notFound))
        case .failure(.request(.client(401))): // handle 401 - not authorized
          completion(.failure(.notAuthorized))
        case .failure: // any other error
          completion(.failure(.generalError))
        }
```

If an error occurs for some other reason after the response is already validated, most probably because of parsing error, an `AlamofireNetworkClient.Error.other(wrappedError)` instance is given to the user.
