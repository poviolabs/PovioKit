# FacebookAuthProvider

Auth provider for social login with Facebook.

## Setup
Please read [official documentation](https://developers.facebook.com/docs/facebook-login/ios) from Facebook for all the details around the setup and integration.

## Usage

```swift
// initialization
let config = FacebookAuthProvider.Config()
let provider = FacebookAuthProvider(with: config)

// signIn user
provider
  .signIn(from: <view-controller-instance>)
  .finally {
    // handle result
  }

// get auth status
let state = FacebookAuthProvider.isAuthorized()

// signOut user
FacebookAuthProvider.signOut() // all provider data regarding the use auth is cleared at this point
```
