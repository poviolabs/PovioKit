# GoogleAuthProvider

Auth provider for social login with Google.

## Setup
Please read [official documentation](https://developers.google.com/identity/sign-in/ios/start-integrating) from Google for all the details around the setup and integration.

## Usage

```swift
let config = GoogleAuthProvider.Config(clientId: "google-client-id")
let provider = GoogleAuthProvider(with: config)
provider.delegate = self

// signIn user
provider.signIn(on: <view-controller-instance>) // a delegate method `googleAuthProviderDidSignIn(with:` or `googleAuthProviderDidFail(with:` is called

// get auth status
GoogleAuthProvider.checkAuthState() { state in
  print("Is authorized", state)
}

// signOut user
GoogleAuthProvider.signOut() // all provider data regarding the use auth is cleared at this point

// handle url
GoogleAuthProvider.shouldHandleURL() // call this from `application:openURL:options:` in UIApplicationDelegate
```
