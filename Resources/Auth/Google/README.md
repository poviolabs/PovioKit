# GoogleAuthProvider

Auth provider for social login with Google.

## Setup
Please read [official documentation](https://developers.google.com/identity/sign-in/ios/start-integrating) from Google for all the details around the setup and integration.

## Usage

```swift
// initialization
let config = GoogleAuthProvider.Config(clientId: "google-client-id")
let provider = GoogleAuthProvider(with: config)

// signIn user
provider
  .signIn(from: <view-controller-instance>)
  .finally {
    // handle result
  }

// get auth status
let state = GoogleAuthProvider.isAuthorized()

// signOut user
GoogleAuthProvider.signOut() // all provider data regarding the use auth is cleared at this point

// handle url
GoogleAuthProvider.shouldHandleURL() // call this from `application:openURL:options:` in UIApplicationDelegate
```
