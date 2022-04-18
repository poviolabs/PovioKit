#  Data Source Protocols

Basic data source protocols used for UITableView or UICollectionView

## Example


```swift
// Example data source
class ExampleDataSource: NSObject, DataSourceType {
  var sections = [ItemsSection]()
  private var items = [ItemsRow]()
}

// MARK: - UITableView DataSource
extension ExampleDataSource: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    numberOfSections()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    numberOfRows(in: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
}

...

// Row
enum ItemsRow: RowType {
  case item
}

...

// Section
enum ItemsSection: SectionType {
  case items([ItemsRow])
  
  var rows: [ItemsRow] {
    switch self {
    case .items(let rows):
      return rows
    }
  }
}
```
