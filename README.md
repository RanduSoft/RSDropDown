# RSDropDown

A fully customizable dropdown component for iOS with Apple-native defaults.

Supports UIKit, SwiftUI, search/autocomplete, Dynamic Type, accessibility, and Storyboards.

## Requirements

- iOS 17+
- Swift 5.10+

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/nicklashansen/RSDropDown.git", from: "3.0.0")
]
```

Or in Xcode: **File > Add Package Dependencies** and enter the repository URL.

## Usage (v3 API)

### UIKit

```swift
import RSDropDown

let dropDown = RSDropDown(frame: CGRect(x: 20, y: 100, width: 300, height: 44))
view.addSubview(dropDown)

// Configuration
dropDown.configuration.style.rowHeight = 45
dropDown.configuration.style.rowBackgroundColor = .systemBackground
dropDown.configuration.style.cornerRadius = 10
dropDown.configuration.chevron.size = 20
dropDown.configuration.chevron.color = .systemRed
dropDown.configuration.list.spacing = 10
dropDown.configuration.list.maxHeight = 180

// Data
dropDown.placeholder = "Pick one"
dropDown.optionArray = ["Option 1", "Option 2", "Option 3"]

// Selection
dropDown.onSelection = { selection in
    print(selection.item.dropDownTitle, selection.index)
}

dropDown.selectedIndex = 0
```

### Chainable API

```swift
let dropDown = RSDropDown(frame: rect)
    .rowHeight(45)
    .rowBackgroundColor(.systemBackground)
    .listMaxHeight(180)
    .searchEnabled(true)
```

### SwiftUI

```swift
import RSDropDown

struct ContentView: View {
    @State private var selection: String?

    var body: some View {
        RSDropDownPicker(
            items: ["Option 1", "Option 2", "Option 3"],
            selection: $selection,
            placeholder: "Pick one"
        )
        .frame(height: 44)
    }
}
```

### Custom Item Types

Conform to `DropDownItem` to use custom models:

```swift
struct Country: DropDownItem, Equatable {
    let name: String
    let flag: String

    var dropDownTitle: String { "\(flag) \(name)" }
    var dropDownImage: String? { nil }
    var dropDownID: AnyHashable { name }
}

let countries = [
    Country(name: "Romania", flag: "🇷🇴"),
    Country(name: "Japan", flag: "🇯🇵"),
    Country(name: "Brazil", flag: "🇧🇷")
]

dropDown.setItems(countries)
```

### Search / Autocomplete

```swift
dropDown.configuration.search.isEnabled = true
dropDown.configuration.search.clearSelectionOnOpen = true
```

## Configuration Reference

All configuration is grouped under `dropDown.configuration`:

| Group | Property | Default | Description |
|---|---|---|---|
| `style` | `rowHeight` | 44 | Row height (Apple standard) |
| `style` | `rowBackgroundColor` | `.secondarySystemGroupedBackground` | Row background |
| `style` | `rowTextColor` | `.label` | Text color |
| `style` | `selectedRowColor` | `.systemFill` | Selected row highlight |
| `style` | `cellFont` | `.preferredFont(forTextStyle: .body)` | Cell font (Dynamic Type) |
| `style` | `showBorder` | `false` | Show list border |
| `style` | `showShadow` | `true` | Show list shadow |
| `style` | `borderColor` | `.separator` | Border color |
| `style` | `borderWidth` | 0 | Border width |
| `style` | `cornerRadius` | 10 | List corner radius |
| `style` | `imageCellIsRounded` | `false` | Round cell images |
| `list` | `maxHeight` | 220 | Maximum list height |
| `list` | `width` | `nil` (match dropdown) | Custom list width |
| `list` | `spacing` | 4 | Spacing between dropdown and list |
| `chevron` | `size` | 12 | Chevron image size |
| `chevron` | `color` | `.secondaryLabel` | Chevron tint color |
| `chevron` | `image` | `chevron.down` | Chevron SF Symbol |
| `behavior` | `hideOnSelect` | `true` | Hide list on selection |
| `behavior` | `showCheckmark` | `true` | Show checkmark on selected row |
| `behavior` | `handleKeyboard` | `true` | Handle keyboard in search mode |
| `behavior` | `flashScrollIndicator` | `true` | Flash scroll indicators on open |
| `behavior` | `scrollToSelection` | `true` | Scroll to selected item on open |
| `behavior` | `hapticFeedback` | `true` | Haptic feedback on selection |
| `search` | `isEnabled` | `false` | Enable search/autocomplete |
| `search` | `clearSelectionOnOpen` | `true` | Clear selection when search opens |
| `animation` | `duration` | 0.25 | Animation duration |

## Callbacks

```swift
// v3 API
dropDown.onSelection = { selection in
    print(selection.item.dropDownTitle, selection.index)
}
dropDown.onDropDownWillAppear = { print("Will appear") }
dropDown.onDropDownDidAppear = { print("Did appear") }
dropDown.onDropDownWillDisappear = { print("Will disappear") }
dropDown.onDropDownDidDisappear = { print("Did disappear") }
```

## Migration from v2

All v2 properties and methods are preserved with `@available(*, deprecated)` annotations. Your existing code will compile with deprecation warnings only.

| v2 | v3 |
|---|---|
| `rowHeight` | `configuration.style.rowHeight` |
| `rowBackgroundColor` | `configuration.style.rowBackgroundColor` |
| `rowTextColor` | `configuration.style.rowTextColor` |
| `selectedRowColor` | `configuration.style.selectedRowColor` |
| `tableViewCellFont` | `configuration.style.cellFont` |
| `hideOptionsOnSelect` | `configuration.behavior.hideOnSelect` |
| `checkMarkEnabled` | `configuration.behavior.showCheckmark` |
| `handleKeyboard` | `configuration.behavior.handleKeyboard` |
| `flashIndicatorWhenOpeningList` | `configuration.behavior.flashScrollIndicator` |
| `scrollToSelectedItem` | `configuration.behavior.scrollToSelection` |
| `showTableViewBorder` | `configuration.style.showBorder` |
| `showTableViewShadow` | `configuration.style.showShadow` |
| `tableViewCornerRadius` | `configuration.style.cornerRadius` |
| `listHeight` | `configuration.list.maxHeight` |
| `listWidth` | `configuration.list.width` |
| `listSpacing` | `configuration.list.spacing` |
| `borderColor` | `configuration.style.borderColor` |
| `borderWidth` | `configuration.style.borderWidth` |
| `chevronSize` | `configuration.chevron.size` |
| `chevronColor` | `configuration.chevron.color` |
| `chevronImage` | `configuration.chevron.image` |
| `isSearchEnabled` | `configuration.search.isEnabled` |
| `clearSearchSelectionOnOpen` | `configuration.search.clearSelectionOnOpen` |
| `animationDuration` | `configuration.animation.duration` |
| `imageCellIsRounded` | `configuration.style.imageCellIsRounded` |
| `didSelect(completion:)` | `onSelection` closure |
| `listWillAppear(completion:)` | `onDropDownWillAppear` |
| `listDidAppear(completion:)` | `onDropDownDidAppear` |
| `listWillDisappear(completion:)` | `onDropDownWillDisappear` |
| `listDidDisappear(completion:)` | `onDropDownDidDisappear` |
| `optionImageArray` | Use `DropDownItem.dropDownImage` |
| `optionIds` | Use `DropDownItem.dropDownID` |
