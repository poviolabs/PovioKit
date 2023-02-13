# GoogleAuthenticator

Auth provider for social login with Google.

## Setup
Please read [official documentation](https://developers.google.com/identity/sign-in/ios/start-integrating) from Google for all the details around the setup and integration.

## Usage

```swift
// initialization
let authenticator = GoogleAuthenticator()

// signIn user
authenticator
  .signIn(from: <view-controller-instance>)
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
