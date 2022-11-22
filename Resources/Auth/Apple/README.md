# AppleAuthProvider

Auth provider for social login with Apple.

## Usage

```swift
let provider = AppleAuthProvider(delegate: self)

// signIn user
provider.signIn() // a delegate method `appleAuthProviderDidSignIn(with:` or `appleAuthProviderDidFail(with:` is called

// get auth status
provider.checkAuthorizationState() // a delegate method `appleAuthProviderIsAuthorized` is called

// signOut user
provider.signOut() // all provider data regarding the use auth is cleared at this point
```
