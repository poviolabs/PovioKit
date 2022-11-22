# GoogleAuthProvider

Auth provider for social login with Google.

## Usage

```swift
let config = GoogleAuthProvider.Config(clientId: "google-client-id")
let provider = GoogleAuthProvider(with: config, delegate: self)

// signIn user
provider.signIn() // a delegate method `googleAuthProviderDidSignIn(with:` or `googleAuthProviderDidFail(with:` is called

// signOut user
provider.signOut() // all provider data regarding the use auth is cleared at this point

// handle url
provider.shouldHandleURL() // call this from `application:openURL:options:` in UIApplicationDelegate
``` 
