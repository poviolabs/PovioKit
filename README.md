<p align="center">
  <img src="./PovioLabs_logo.png" alt="Povio Labs logo" height="180">
</p>

# PovioKit

[![Version](https://img.shields.io/cocoapods/v/PovioKit.svg?style=flat)](https://cocoapods.org/pods/PovioKit)
[![License](https://img.shields.io/cocoapods/l/PovioKit.svg?style=flat)](https://cocoapods.org/pods/PovioKit)
[![Platform](https://img.shields.io/cocoapods/p/PovioKit.svg?style=flat)](https://cocoapods.org/pods/PovioKit)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://swift.org/blog/swift-5-released/)

Welcome to **PovioKit**, a modular collection of cocoapods libraries, written in Swift.

## List of available libraries

### Extensions
* [UICollectionView](/PovioKit/Classes/Extensions/UIKit/UICollectionView+Povio.swift)
* [UITableView](/PovioKit/Classes/Extensions/UIKit/UITableView+Povio.swift)
* [UIView](/PovioKit/Classes/Extensions/UIKit/UIView+Povio.swift)
* [UIColor](/PovioKit/Classes/Extensions/UIKit/UIColor+Povio.swift)
* [UIDevice](/PovioKit/Classes/Extensions/UIKit/UIDevice+Povio.swift)
* [UIImage](/PovioKit/Classes/Extensions/UIKit/UIImage+Povio.swift)
* [Collection](/PovioKit/Classes/Extensions/Foundation/Collection+Povio.swift)
* [String](/PovioKit/Classes/Extensions/Foundation/String+Povio.swift)
* [URL](/PovioKit/Classes/Extensions/Foundation/URL+Povio.swift)
* [Optional](/PovioKit/Classes/Extensions/Foundation/Optional+Povio.swift)

### Utilities
* [AttributedStringBuilder](/PovioKit/Classes/Utilities/AttributedStringBuilder/)
* [StartupService](/PovioKit/Classes/Utilities/StartupService/)
* [Broadcast](/PovioKit/Classes/Utilities/Broadcast/)


### UIViews
* [GradientView](/PovioKit/Classes/Views/GradientView/)

## Installation

PovioKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PovioKit'
```

This way you'll install all subspecs available. However, you could option in to install only selected subspec. Her is an example how to install `StartupService`:

```ruby
pod 'PovioKit/Utilities/StartupService'
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## License

PovioKit is available under the MIT license. See the LICENSE file for more info.
