# FacebookAuthenticator

Auth provider for social login with Facebook.

## Setup
Please read [official documentation](https://developers.facebook.com/docs/facebook-login/ios) from Facebook for all the details around the setup and integration.

## Usage

```swift
// initialization
let authenticator = FacebookAuthenticator()

// signIn user with default permissions
authenticator
  .signIn(from: <view-controller-instance>)
  .finally {
    // handle result
  }

// signIn user with custom permissions  
authenticator
  .signIn(from: <view-controller-instance>, with: [<array-of-custom-permissions>])
  .finally {
    // handle result
  }

// get authentication status
let state = authenticator.isAuthenticated

// signOut user
authenticator.signOut() // all provider data regarding the use auth is cleared at this point

// handle url
authenticator.canOpenUrl(_: application: options:) // call this from `application:openURL:options:` in UIApplicationDelegate
```
