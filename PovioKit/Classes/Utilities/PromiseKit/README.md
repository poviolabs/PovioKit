# PromiseKit

Lightweight `Promise` pattern implementation inspired by https://www.swiftbysundell.com/posts/under-the-hood-of-futures-and-promises-in-swift

## Usage

A common pattern used by developers for handling API results is to inject a completion handler closure as a function argument to handle the result. For instance:

```Swift
func fetchUser(with id: User.ID, completion: @escaping (Result<User, Error>) -> Void) {
  apiRequest {
    completion($0)
  }
}

// call site:

fetchUser(with: 10) { result in
  switch result {
  case .success(let user):
    ...
  case .failure(let error):
    ...
  }
}
```

Using Promise pattern we can instead solve the problem with something like:

```Swift
func fetchUser(with id: User.ID) -> Promise<User, Error> {
  let promise = Promise<User, Error>()
  apiRequest {
    promise.resolve(with: $0)
    // or promise.reject(with: error) if error occurred
  }
  return promise
}

// call site:

let result = fetchUser(with: 10)

...

result.observe {
  switch $0 {
  case .success(let user):
    ...
  case .failure(let error):
    ...
  }
}
```

Both solutions are quite similar, the main advantage of using promises though is that the result can be observed by more than one actor. 
Also, since a promise is just an object, we can also pass it around, whereas we can't do that when using closure pattern.

Promises also contain some usefull properties:

```Swift
let promise = Promise<,>()
...
print(promise.isFullfiled) // `true` if result is present, otherwise `false`
print(promise.isRejected) // `true` if error occured, otherwise `false`
print(promise.isAwaiting) // `true` only if both `isFullfiled` and `isRejected` are `false`, otherwise `false`
print(promise.value) // `nil` if no value is present, otherwise value of the result
print(promise.error) // `nil` if no error (yet) occured, otherwise error
```
