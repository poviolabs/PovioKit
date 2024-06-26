# Logger

Simple, yet performant console logger built on top of [OSLog](https://developer.apple.com/documentation/os/logging) framework. 

## Log Levels

There are 6 levels defined to choose from
* info
* warn
* debug
* error
* none
* all

The default `logLevel` is set to `info`. To change it, just call
```swift
Logger.shared.logLevel = .debug
```

## Interface methods

There are four main static methods that you can interact with the logger
* info(_ message: String, params: Logger.Params? = nil)
* debug(_ message: String, params: Logger.Params? = nil)
* warning(_ message: String, params: Logger.Params? = nil)
* error(_ message: String, params: Logger.Params? = nil)

```swift
Logger.debug("Something went wrong", params: ["objectId": 1])
```

## Source code
You can find source code [here](/Sources/Core/Logger/Logger.swift).
