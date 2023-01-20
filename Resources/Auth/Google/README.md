# GoogleAuthenticator

Auth provider for social login with Google.

## Setup
Please read [official documentation](https://developers.google.com/identity/sign-in/ios/start-integrating) from Google for all the details around the setup and integration.

## Usage

```swift
// initialization
let config = GoogleAuthenticator.Config(clientId: "google-client-id")
let provider = GoogleAuthenticator(with: config)

// signIn user
provider
  .signIn(from: <view-controller-instance>)
  .finally {
    // handle result
  }

// get auth status
let state = GoogleAuthenticator.isAuthorized()

// signOut user
GoogleAuthenticator.signOut() // all provider data regarding the use auth is cleared at this point

// handle url
GoogleAuthenticator.shouldHandleURL() // call this from `application:openURL:options:` in UIApplicationDelegate
```
