# FacebookAuthenticator

Auth provider for social login with Facebook.

## Setup
Please read [official documentation](https://developers.facebook.com/docs/facebook-login/ios) from Facebook for all the details around the setup and integration.

## Usage

```swift
// initialization
let config = FacebookAuthenticator.Config()
let provider = FacebookAuthenticator(with: config)

// signIn user
provider
  .signIn(from: <view-controller-instance>)
  .finally {
    // handle result
  }

// get auth status
let state = FacebookAuthenticator.isAuthorized()

// signOut user
FacebookAuthenticator.signOut() // all provider data regarding the use auth is cleared at this point
```
