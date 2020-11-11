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

##### UIKit
* [UIView](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/UIKit/UIView+Povio.swift)
* [UICollectionView](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/UIKit/UICollectionView+Povio.swift)
* [UITableView](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/UIKit/UITableView+Povio.swift)
* [UIColor](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/UIKit/UIColor+Povio.swift)
* [UIDevice](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/UIKit/UIDevice+Povio.swift)
* [UIImage](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/UIKit/UIImage+Povio.swift)
* [UIEdgeInsets](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/UIKit/UIEdgeInsets+Povio.swift)

##### Foundation
* [String](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/Foundation/String+Povio.swift)
* [Data](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/Foundation/Data+Povio.swift)
* [Collection](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/Foundation/Collection+Povio.swift)
* [URL](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/Foundation/URL+Povio.swift)
* [Optional](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/Foundation/Optional+Povio.swift)
* [Result](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/Foundation/Result+Povio.swift)

##### MapKit
* [MKMapView](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/MapKit/MKMapView+PovioKit.swift)
* [MKPolygon](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/MapKit/MKPolygon+PovioKit.swift)
* [MKAnnotationView](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/MapKit/MKAnnotationView+PovioKit.swift)
* [MKCircle](https://github.com/poviolabs/PovioKit/blob/master/Sources/Extensions/MapKit/MKCircle+PovioKit.swift)

### Utilities
* [AttributedStringBuilder](https://github.com/poviolabs/PovioKit/blob/master/Resources/Utilities/AttributedStringBuilder/)
* [StartupService](https://github.com/poviolabs/PovioKit/blob/master/Resources/Utilities/StartupService/)
* [Broadcast](https://github.com/poviolabs/PovioKit/blob/master/Resources/Utilities/Broadcast/)
* [PromiseKit](https://github.com/poviolabs/PovioKit/blob/master/Resources/Utilities/PromiseKit/)
* [ColorInterpolator](https://github.com/poviolabs/PovioKit/blob/master/Resources/Utilities/ColorInterpolator/)
* [DispatchTimer](https://github.com/poviolabs/PovioKit/blob/master/Resources/Utilities/DispatchTimer/)
* [Logger](https://github.com/poviolabs/PovioKit/blob/master/Resources/Utilities/Logger/)
* [Throttler](https://github.com/poviolabs/PovioKit/blob/master/Resources/Utilities/Throttler/)
* [SignInWithApple](https://github.com/poviolabs/PovioKit/blob/master/Resources/Utilities/SignInWithApple/)

### Networking
* [AlamofireNetworkClient](https://github.com/poviolabs/PovioKit/blob/master/Resources/Networking/AlamofireNetworkClient/)

### UIViews
* [GradientView](https://github.com/poviolabs/PovioKit/blob/master/Resources/Views/GradientView/)
* [PaddingLabel](https://github.com/poviolabs/PovioKit/blob/master/Resources/Views/PaddingLabel/)

## Installation

### Swift Package Manager

PovioKit is available through [SPM](https://swift.org/package-manager/). To install it, click `File` -> `Swift Packages` -> `Add Package Dependency` and enter `https://github.com/poviolabs/PovioKit`.


### CocoaPods

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
