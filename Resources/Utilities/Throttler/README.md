# Throttler

Job manager executing only the latest scheduled job, delayed.

## Usage

`Throttler` can be used to simplify search functionality implementation, where after inputing a query a search request is executed. But executing a request on each key press would be quite an overhead, and the throttler comes to the rescue.

```swift
class SearchWorker {
  let throttler = Throttler(delay: .miliseconds(500))

  func search(query: String, completion: (SearchResults) -> Void) {
    throttler.execute {
      // this block will get executed after `0.5` seconds. 
      // if `search` is called multiple times during this period, only the latest call will be dispatched 
      self.performApiRequest(query: query, completion: completion)
    }
  }
}
```

## Source code
You can find source code [here](/Sources/Utilities/Throttler/Throttler.swift).
