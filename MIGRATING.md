## Migration Guides

### Migration from versions < 1.5.0
* [Networking] File `OAuthRequestInterceptor` has been completely removed due to some critical issues. We encourage you to migrate to Alamofire's `Authenticator` protocol. Instructions can be found [here](Resources/Networking/AlamofireNetworkClient#oauth).

### Migration from versions < 1.4.0
* [UI] New product `PovioKitUI` is introduced. In order to use it, please re-intall dependency and select it from product selection list.
* [Networking] Method `asJson` was marked as deprecated. Please stop using it soon.
* [PromiseKit] Removed deprecated methods.

### Migrating from versions < 1.3.1
* [Networking] OAuthStorage protocol now accepts `OAuthContainer` only instead of separate values for `accessToken` and `refreshToken`. Change your implementation accordingly.

### Migrating from versions < 1.3.0
* [PromiseKit] Changes required due to deprecated methods. You'll need to rename them in order to avoid warnings. `chain` was renamed to `flatMap`, `observe` was renamed to `finally`, `onFailure` was renamed to `catch`, `chainError` was renamed to `flatMapError`, `onSuccess` was renamed to `then`.
