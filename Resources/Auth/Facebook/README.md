# FacebookAuthProvider

Auth provider for social login with Facebook.

## Setup
Please read [official documentation](https://developers.facebook.com/docs/facebook-login/ios) from Facebook for all the details around the setup and integration.

## Usage

```swift
let config = FacebookAuthProvider.Config()
let provider = FacebookAuthProvider(with: config)
provider.delegate = self

// signIn user
provider.signIn(on: <view-controller-instance>) // a delegate method `facebookAuthProviderDidSignIn(with:` or `facebookAuthProviderDidFail(with:` is called

// get auth status
FacebookAuthProvider.checkAuthState() { state in
  print("Is authorized", state)
}

// signOut user
FacebookAuthProvider.signOut() // all provider data regarding the use auth is cleared at this point

// handle url
GoogleAuthProvider.shouldHandleURL() // call this from `application:openURL:options:` in UIApplicationDelegate
```
