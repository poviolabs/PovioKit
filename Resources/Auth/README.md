# Auth

Auth packages with support for social providers as listed below.

### Main packages
- [Core](Core)

### Social Authenticators packages
- [Apple](Apple)
- [Google](Google)
- [Facebook](Facebook)

## Use of SocialAuthenticator
You can leverage use of `SocialAuthenticator` as to simplify managing multiple instances at once.

```swift
let manager = SocialAuthenticator(authenticators: [AppleAuthenticator(), FacebookAuthenticator()])

// signIn user with Apple
let appleAuthenticator = manager.authenticator(for: AppleAuthenticator.self)
appleAuthenticator?
  .signIn(from: <view-controller-instance>, with: .random(length: 32))
  .finally {
    // handle result
  }
  
// signIn user with Facebook
let facebookAuthenticator = manager.authenticator(for: FacebookAuthenticator.self)
facebookAuthenticator?
  .signIn(from: <view-controller-instance>, with: [.email])
  .finally {
    // handle result
  }

// sign out currently signedIn authenticator
manager.signOut()

// check if any authenticator is authenticated
manager
  .isAuthenticated
  .finally {
    // check result
  }
```
