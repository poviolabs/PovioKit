# AlamofireRestClient

High-level `Alamofire` REST client abstraction.

## Examples

Retreiving JSON object from an endpoint is as simple as:

```swift
let client = AlamofireNetworkClient()
let json = client
  .request(method: .get, 
           endpoint: "http://my-amazing-api.com/endpoint")
  .validate() // makes sure status code is in 200..<300
  .json() // parse `JSON` from the response
```

Often we want to serialize the response into a domain model:

```swift
let client = AlamofireNetworkClient()
let model = client
  .request(method: .get, 
           endpoint: "http://my-amazing-api.com/endpoint")
  .validate() // makes sure status code is in 200..<300
  .decode(MyModel.self) // parse `MyModel` from the response
```

The `request` method returns a `AlamofireRestClient.Request` object, on which we can perform other operations as well:

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

Aside from `JSON` and `Decodable` parsing, `AlamofireRestClient.Request` also enables us to also parse `Data` and `()`:

```swift
let client = AlamofireNetworkClient()
let request = client
  .request(method: .get, 
           endpoint: "http://my-amazing-api.com/endpoint")

let data = request.data() // parse `Data`
...
let _ = request.singleton() // this actually doesn't parse anything, but instead resolves if request succeeds
```

Sometimes we want to configure the way objects are decoded. We do that by providing a configuration closure to the `request` method:

```swift
let configurator = { (decoder: JSONDecoder) -> Void in 
  decoder.dateDecodingStrategy = .formatted(CustomDateFormatter())
  decoder.keyDecodingStrategy = .convertFromSnakeCase
}
let client = AlamofireNetworkClient()
let model = client
  .request(method: .get, 
           endpoint: "http://my-amazing-api.com/endpoint",
           decoderConfigurator: configurator)
  .validate() // makes sure status code is in 200..<300
  .decode(MyModel.self) // parse `MyModel` from the response
```

Sending data to the server is also a common task, which is very easy to do to using `AlamofireRestClient`. We have two options:

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
 
  - Sending a domain model object directly:

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

Similarily as configuring decoder, we can also provide an encoder configuration closure for custom encoding:

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
           encode: object,
           encoderConfigurator: { $0.keyEncodingStrategy = .convertToSnakeCase })
```

## Error handling

`AlamofireRestClient` is designed so that error handling would be as intuitive as possible. `AlamofireRestClient.Error` type has two cases - it's either a `request` error or some other error (wrapping the underlying error).

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
    .singleton()
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

If an error occurs for some other reason after the response is already validated, most probably because of parsing error, an `AlamofireRestClient.Error.other(wrappedError)` instance is given to the user.
