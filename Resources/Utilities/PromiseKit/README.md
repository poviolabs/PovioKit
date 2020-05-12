# PromiseKit

Lightweight `Promise` pattern implementation.

## Usage

A common pattern used by developers for handling asynchronous results is to inject a completion handler closure as a function argument to handle the result. For instance:

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

Using `Promise` pattern we can instead solve the problem like this:

```Swift
func fetchUser(with id: User.ID) -> Promise<User> {
  Promise { seal in
    apiRequest {
      seal.resolve(with: $0)
      // or seal.reject(with: Error) if error occurred
    }
  }
}

// call site:

let promise = fetchUser(with: 10)

...

promise.onSuccess { value in
  ...
}

promise.onFailure { error in
...
}

// or

promise.observe {
  switch $0 {
  case .success(let user):
    ...
  case .failure(let error):
    ...
  }
}
```

The advantage of using Promises is that they simplify asynchronous programming so that we as programmers can focus on _what_ instead of _how_. This especially becomes apparent when dealing with several asynchronous operations at the same time.

## Chaining Promises

### The pyramid of doom

Often, we find ourselves writing code that looks something like this:

```Swift
func download(_ handler: @escaping (Result<C, Error>) -> Void) {
 downloadA { resultA in
  switch resultA {
  case .success(let a):
   downloadB(input: a) { resultB in
    switch resultB {
    case .success(let b):
     downloadC(input: b) { resultC in
      switch resultC {
      case .success(let c):
       handler(.success(c))
      case .failure(let error):
       handler(.failure(error))
      }
     }
    case .failure(let error):
     handler(.failure(error))
    }
   }
  case .failure(let error):
   handler(.failure(error))
  }
 }
}

func downloadA(_ handler: @escaping (Result<A, Error>) -> Void) {
}
func downloadB(input: A, _ handler: @escaping (Result<B, Error>) -> Void) {
}
func downloadC(input: B, _ handler: @escaping (Result<C, Error>) -> Void) {
}
```

The above solution has a couple of issues:

* it is hard to read
* it is error-prone
* lot's of code duplication - handling `success` / `failure` cases for every subsequent invocation
* _it is not Swifty_

Can we do better? Let's try to refactor the code using `PromiseKit`:

```Swift
func download() -> Promise<C> {
 downloadA()
   .chain(with: downloadB)
   .chain(with: downloadC)
}

func downloadA() -> Promise<A> {
}

func downloadB(input: A) -> Promise<B> {
}

func downloadC(input: C) -> Promise<C> {
}
```

Much better! The code is clean and easy to read. 

### Chaining

The core idea of Promises is that they are _composable_. What that means is that if we have a `Promise<A>` and a function `(A) -> Promise<B>` we can create `Promise<B>`. 
Behind the scene, Promise itself handles `success` and `failure` cases. If at any point in the chain of promises one of them fails, the whole chain fails as well.

This mechanism is encapsulated by the `chain` method. Use `chain` when you want to invoke another Promise after the current Promise succeeds. Note that types must match: if you want to chain a `Promise<T>` then you must provide a function of type `(T) -> Promise<U>` (U can be any type).

## API

Now that we understand the core idea behind promises (which, again, is _composability_), let's discuss some other abstractions built on top of that.

1. `map`

Use `map` when you want to transform the (_future_) value of the promise into some other value.

Example:

```swift
Promise<Int>.value(10)
  .map { String($0) } // -> transforms into Promise<String>
```

2. `compactMap`

`compactMap` is almost identical to `map` except that it creates a rejected promise if provided closure returns `nil`.

Example:

```swift
Promise<String>.value("10")
  .compactMap { Int($) } // -> transforms into Promise<Int>
  .onSuccess { print($0 } // -> output is "10"
Promise<String>.value("not a number")
  .compactMap { Int($) } // -> transforms into Promise<Int>
  .onSuccess { print($0 } // -> will not get called!
```

3. `combine`

`combine` lets us group multiple promises into a single promise, which contains the result of all promises. 

Example:

```swift
let promises: [Promise<String>] = ...
comine(promises: promises)
  .map { (values: [String]) in ... } // -> do some work on list of Strings
```

We can combine promises of different types as well:

```swift
let p1 = Promise<Int> = ...
let p2 = Promise<String> = ...
combine(p1, p2)
  .map { (x: Int, y: String) in ... } // -> do some work
```

----

`PromiseKit` provides other useful APIs which help us in specific situations. For example, we can directly decode `Data` into a `Decodable` conforming type:

```swift
Promise<Data>.value(json)
   .decode(type: Model.self, decoder: JSONDecoder()) // -> produces `Promise<Model>`
```

When the underlying type of the promise is a `Sequence`, we gain additional useful abstractions. In fact, most of the standard higher-order functions you'd expect on sequences are implemented in the `PromiseKit`. 

Let's take a look at a couple of examples:

```swift
// map
Promise<[Int]>.value([1, 2, 3])
  .mapValues { $0 * 2 } // -> [2, 4, 6]
```

```swift
// filter
Promise<[Int]>.value([1, 2, 3, 4, 5, 6])
  .filterValues { $0 % 2 == 0 } // -> [2, 4, 6]
```

```swift
// reduce
Promise<[Int]>.value([1, 2, 3])
  .reduceValues(+) // -> 6
```

----

One interesting use-case is when we want to map elements of the sequence into new promises. Use `flatMapValues` in such cases:

```swift
func fetch(by id: String) -> Promise<Model> { ... }

Promise<[String]>.value(["id1", "id2", "id3"])
  .flatMapValues(with: fetch)
  .map { (models: [Model]) in ...  } 
```

This is a common pattern when developing apps. We first fetch remote API to get a list of items. Then, for every item on the list, we want to fetch another API to get details of an item. With promises, this is a piece of cake.
