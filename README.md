<p align="center">
    <img src="https://raw.githubusercontent.com/poviolabs/PovioKit/master/PovioKit.png" width="400" max-width="90%" alt="PovioKit" />
</p>

<p align="center">
    <a href="https://cocoapods.org/pods/PovioKit">
        <img src="https://img.shields.io/cocoapods/v/PovioKit.svg?style=flat" alt="Version" />
    </a>
    <a href="https://cocoapods.org/pods/PovioKit">
        <img src="https://img.shields.io/cocoapods/l/PovioKit.svg?style=flat" alt="License" />
    </a>
    <a href="https://cocoapods.org/pods/PovioKit">
        <img src="https://img.shields.io/cocoapods/p/PovioKit.svg?style=flat" alt="Platform" />
    </a>
    <a href="https://swift.org/blog/swift-5-released/">
        <img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift" />
    </a>
    <a href="https://travis-ci.com/poviolabs/PovioKit/branches">
        <img src="https://img.shields.io/travis/com/poviolabs/PovioKit.svg" alt="Travis status" />
    </a>
</p>

<p align="center">
    Welcome to <b>PovioKit</b>. A modular collection of cocoapods libraries. Written in Swift.
</p>

## List of available libraries

### Extensions
* [UICollectionView](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Extensions/UIKit/UICollectionView+Povio.swift)
* [UITableView](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Extensions/UIKit/UITableView+Povio.swift)
* [UIView](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Extensions/UIKit/UIView+Povio.swift)
* [UIColor](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Extensions/UIKit/UIColor+Povio.swift)
* [UIDevice](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Extensions/UIKit/UIDevice+Povio.swift)
* [UIImage](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Extensions/UIKit/UIImage+Povio.swift)
* [Collection](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Extensions/Foundation/Collection+Povio.swift)
* [String](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Extensions/Foundation/String+Povio.swift)
* [URL](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Extensions/Foundation/URL+Povio.swift)
* [Optional](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Extensions/Foundation/Optional+Povio.swift)

### Utilities
* [AttributedStringBuilder](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Utilities/AttributedStringBuilder/)
* [StartupService](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Utilities/StartupService/)
* [Broadcast](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Utilities/Broadcast/)
* [PromiseKit](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Utilities/PromiseKit/)
* [ColorInterpolator](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Utilities/ColorInterpolator/)
* [DispatchTimer](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Utilities/DispatchTimer/)
* [Logger](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Utilities/Logger/)
* [Throttler](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Utilities/Throttler/)


### UIViews
* [GradientView](https://github.com/poviolabs/PovioKit/blob/master/PovioKit/Classes/Views/GradientView/)

## Installation

PovioKit is available through [CocoaPods](https://cocoapods.org). To install it, add the following line to your Podfile:

```ruby
pod 'PovioKit'
```

This way you'll install all subspecs available. However, you could opt-out installing only selected subspec. Her is an example of how to install `StartupService`:

```ruby
pod 'PovioKit/Utilities/StartupService'
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## License

PovioKit is available under the MIT license. See the LICENSE file for more info.
