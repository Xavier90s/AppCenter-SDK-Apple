import UIKit

class EventPropertiesTableSection : PropertiesTableSection {
  typealias EventPropertyType = MSAnalyticsTypedPropertyTableViewCell.EventPropertyType
  typealias PropertyState = MSAnalyticsTypedPropertyTableViewCell.PropertyState

  private var typedProperties = [PropertyState]()

  override func loadCell(row: Int) -> UITableViewCell {
    guard let cell: MSAnalyticsTypedPropertyTableViewCell = loadCellFromNib() else {
      preconditionFailure("Cannot load table view cell")
    }
    cell.state = typedProperties[row - self.propertyCellOffset]
    cell.onChange = { state in
      self.typedProperties[row - self.propertyCellOffset] = state
    }
    return cell
  }

  override func getPropertyCount() -> Int {
    return typedProperties.count
  }

  override func addProperty() {
    let count = getPropertyCount()
    typedProperties.insert(("key\(count)", EventPropertyType.String, "value\(count)"), at: 0)
  }

  override func removeProperty(atRow row: Int) {
    typedProperties.remove(at: row - self.propertyCellOffset)
  }

  func eventProperties() -> Any? {
    if typedProperties.count < 1 {
      return nil
    }
    var onlyStrings = true
    var propertyDictionary = [String: String]()
    let eventProperties = MSEventProperties()
    for property in typedProperties {
      switch property.type {
      case .String:
        eventProperties.setString(property.value as! String, forKey:property.key)
        propertyDictionary[property.key] = (property.value as! String)
      case .Double:
        eventProperties.setDouble(property.value as! Double, forKey:property.key)
        onlyStrings = false
      case .Long:
        eventProperties.setInt64(property.value as! Int64, forKey:property.key)
        onlyStrings = false
      case .Boolean:
        eventProperties.setBool(property.value as! Bool, forKey:property.key)
        onlyStrings = false
      case .DateTime:
        eventProperties.setDate(property.value as! Date, forKey:property.key)
        onlyStrings = false
      }
    }
    return onlyStrings ? propertyDictionary : eventProperties
  }
}
