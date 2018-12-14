#  Throttler

Job manager executing only latest scheduled job after set delay.

## Example

We used `Throttler` for search functionality, where we delayed requesting search results. Executing a request each key press would be quite an overhead, and the throttler comes to the rescue.

Usage example:

```Swift
class SearchWorker {
  let throttler = Throttler(delay: 0.5)

  func search(query: String, completion: (SearchResults) -> Void) {
    throttler.execute {
      // this block will get executed after `0.5` seconds. 
      // if `search` is called multiple times during this period, only latest call will be dispatched 
      self.performApiRequest(query: query, completion: completion)
    }
  }
}
```
