#  Delegated

## The problem

Very often we are required to delegate events from one entity to another. A common pattern in iOS is the so called `Delegate` pattern:

```swift
protocol SomeCellDelegate: AnyObject {
  func didTapButton()
}

class SomeCell: UITableViewCell {
  let button = UIButton()
  weak var delegate: SomeCellDelegate?
  ...
  
  @objc func buttonAction() {
    delegate?.didTapButton()
  }
}

...

class Controller: UIViewController, UITableViewDataSource, SomeCellDelegate {
  ...
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(SomeCell.self, at: indexPath)
    cell.delegate = self
    return cell
  }
  
  ...
  
  func didTapButton() {
    // do something useful
  }
}
```

The above example is fine, it works well, the API is clean and familiar. So what's the catch?
The problem with the delegate pattern is is that there is a substantial amount of boilerplate code and it just doesn't look _modern_.
A more modern approach used by developers nowadats is the _delegation through closures_ pattern. Let's see it in action:

```swift
class SomeCell: UITableViewCell {
  let button = UIButton()
  var didTapButtonCallback: (() -> Void)?
  ...
  
  @objc func buttonAction() {
    didTapButtonCallback?()
  }
}

...

class Controller: UIViewController, UITableViewDataSource {
  ...
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(SomeCell.self, at: indexPath)
    cell.didTapButtonCallback = {
      // do something useful
    }
    return cell
  }
}
```

Much better! There is less code and hopefully, the code itself is easier to read. **BUT:** we introduced a **memory leak**!  There is a reference cycle between the _Controller_ and the _SomeCell_ instances!
An astute reader should already be jumping and yelling the solution: _just add `[weak self]`_ ...

```swift
class Controller: UIViewController, UITableViewDataSource {
  ...
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(SomeCell.self, at: indexPath)
    cell.didTapButtonCallback = { [weak self] in
      guard let self = self else { return }
      // do something useful
    }
    return cell
  }
}
```

and there problem is gone, right?
Indeed, we got rid of the memory leak, but in some sense, we made things worse, not better. In what way is that you might ask?
Well, when using the `Delegate` pattern, it was the responsibility of the designer of the API for not introducing the memory leak, but now it is the user's of the API. And it is wery easi to overlook the `[weak self]`, especially by not experienced developers. And even if we never overlook it, it requires a great deal of code duplication.

## Solution

By using the `Delegated` module, we get the best of both worlds: automatic memory leak prevention and no boilerplate.

Let's see it in action:

```swift
class SomeCell: UITableViewCell {
  let button = UIButton()
  let callback = Delegated<Void, Void>()
  ...
  
  @objc func buttonAction() {
    callback()
  }
}

...

class Controller: UIViewController, UITableViewDataSource {
  ...
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(SomeCell.self, at: indexPath)
    cell.callback.delegate(to: self) { self in
      guard let self = self else { return }
      // do something useful
    }
    return cell
  }
}
```

### Inspired by
https://medium.com/anysuggestion/preventing-memory-leaks-with-swift-compile-time-safety-49b845df4dc6
