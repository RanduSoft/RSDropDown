# RSDropDown

A beautiful and fully customizable DropDown component for iOS.

Supports search and Storyboards out of the box.

## Example
```swift
@IBOutlet private weak var dropDown: RSDropDown! // add a new UITextField in Storyboard then set its class to RSDropDown
    
func setupDropDown() {
    // optional customization
    self.dropDown.borderStyle = .none
    self.dropDown.backgroundColor = .systemBackground
    self.dropDown.textColor = .label
    self.dropDown.borderColor = .systemGreen
    self.dropDown.borderWidth = 1
    self.dropDown.rowBackgroundColor = .systemBackground
    self.dropDown.font = .systemFont(ofSize: 15, weight: .medium)
    self.dropDown.tableViewCellFont = .systemFont(ofSize: 15, weight: .medium)
    self.dropDown.tableViewCornerRadius = 8
    self.dropDown.chevronSize = 20
    self.dropDown.chevronColor = .systemRed
    self.dropDown.showTableViewBorder = true
    self.dropDown.showTableViewShadow = false
    self.dropDown.cornerRadius = 10
    self.dropDown.padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    self.dropDown.isSearchEnabled = false // set to `true` for the textfield to be editable and provide autocomplete suggestions
    self.dropDown.clearSearchSelectionOnOpen = false // valid only when `isSearchEnabled` is `true`
    
    // setup
    //self.dropDown.listWidth = 380
    self.dropDown.listSpacing = 10
    self.dropDown.rowHeight = 45
    self.dropDown.listHeight = self.dropDown.rowHeight * 4 // 4 items visible
    
    self.dropDown.placeholder = "Pick one" // optional. if no placeholder, the first item from optionArray will show
    self.dropDown.optionArray = (1...500).compactMap { "Option \($0)" }
    self.dropDown.didSelect { selectedItemText, selectedItemIndex, selectedItemId in
        print(selectedItemText, selectedItemIndex, selectedItemId)
    }
    self.dropDown.selectedIndex = 2 // default selected index, optional. if not set, placeholder will show
}
```
