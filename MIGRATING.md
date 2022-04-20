## Migration Guides

### Migrating from versions < 1.3.1
* [Networking] OAuthStorage protocol now accepts `OAuthContainer` only instead of separate values for `accessToken` and `refreshToken`. Change your implementation accordingly.

### Migrating from versions < 1.3.0
* [PromiseKit] Changes required due to deprecated methods. You'll need to rename them in order to avoid warnings. `chain` was renamed to `flatMap`, `observe` was renamed to `finally`, `onFailure` was renamed to `catch`, `chainError` was renamed to `flatMapError`, `onSuccess` was renamed to `then`.
