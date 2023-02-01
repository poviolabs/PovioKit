# Auth

Auth packages with support for social providers as listed below.

### Main packages
- [Core](Core)

### Social Authenticators packages
- [Apple](Apple)
- [Google](Google)
- [Facebook](Facebook)

## Usage
You can leverage use of `SocialAuthenticationManager` as to simplify managing multiple instances at once.

### Use SocialAuthenticationManager directly as is
```swift
let manager = SocialAuthenticationManager(authenticators: [AppleAuthenticator(), FacebookAuthenticator()])

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
  
// return currently authenticated authenticator
let authenticated: Authenticator? = manager.authenticator

// sign out currently signedIn authenticator
manager.signOut()

// check if any authenticator is authenticated
let boolValue = manager.isAuthenticated

// check if authenticated authenticator can open url
let canOpen = manager.canOpenUrl(<url>, application: <app>, options: <options>) 
```

### Use SocialAuthenticationManager with wrapper
```swift
final class WrapperManager {
  private let socialAuthManager: SocialAuthenticationManager
  
  init() {
    socialAuthManager = SocialAuthenticationManager(authenticators: [
      AppleAuthenticator(),
      GoogleAuthenticator(),
      SnapchatAuthenticator()
    ])
  }
}

extension AuthManager: Authenticator {
  var isAuthenticated: Authenticated {
    socialAuthManager.isAuthenticated
  }
  
  var currentAuthenticator: Authenticator? {
    socialAuthManager.currentAuthenticator
  }
  
  func authenticator<A: Authenticator>(for type: A.Type) -> A? {
    socialAuthManager.authenticator(for: type)
  }
  
  func signOut() {
    socialAuthManager.signOut()
  }
  
  func canOpenUrl(_ url: URL, application: UIApplication, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    socialAuthManager.canOpenUrl(url, application: application, options: options)
  }
}
```

### Create a new authenticator
You can easily add new authenticator that is not built-in with PovioKitAuth package.

```swift
final class SnapchatAuthenticator: Authenticator {
  public func signIn(from presentingViewController: UIViewController) -> Promise<Response> {
    Promise { seal in
      SCSDKLoginClient.login(from: presentingViewController) { [weak self] success, error in
        guard success, error == nil else {
          seal.reject(with: error)
          return
        }
        
        let query = "{me{displayName, bitmoji{avatar}}}"
        let variables = ["page": "bitmoji"]
        SCSDKLoginClient.fetchUserData(withQuery: query, variables: variables) { resources in
          ...
          seal.resolve(with: response)
        }
      }
    }
  }
  
  func signOut() {
    SCSDKLoginClient.clearToken()
  }
  
  var isAuthenticated: Authenticated {
    SCSDKLoginClient.isUserLoggedIn
  }
  
  func canOpenUrl(_ url: URL, application: UIApplication, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    SCSDKLoginClient.application(application, open: url, options: options)
  }
}
```
