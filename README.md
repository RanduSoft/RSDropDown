# RSDropDown

A dropdown component for iOS with two built-in styles: **Liquid Glass** (default, iOS 26+) and **Classic Apple**.

Supports UIKit, SwiftUI, search/autocomplete, custom item types, Dynamic Type, accessibility, and Storyboards.

![UIKit1](https://i.imgur.com/1gl0Nq0.png)
![UIKit2](https://i.imgur.com/hs0Z9ho.png)
![SwiftUI1](https://i.imgur.com/eNhUL5H.png)
![SwiftUI2](https://i.imgur.com/XmPAkpy.png)

## Requirements

- iOS 17+
- Swift 6.1+
- Xcode 26+

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/RanduSoft/RSDropDown.git", from: "3.0.0")
]
```

Or in Xcode: **File > Add Package Dependencies** and enter the repository URL.

## Quick Start

### UIKit

```swift
import RSDropDown

let dropDown = RSDropDown(frame: CGRect(x: 20, y: 100, width: 300, height: 44))
dropDown.placeholder = "Pick one"
dropDown.optionArray = ["Option 1", "Option 2", "Option 3"]

dropDown.onSelection = { selection in
    print(selection.item.dropDownTitle, selection.index)
}

view.addSubview(dropDown)
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

## Style Presets

RSDropDown ships with two presets. The default is **Liquid Glass**.

### Liquid Glass (Default)

Uses the native SwiftUI `.glassEffect()` modifier on iOS 26+ for full Liquid Glass rendering (reflections, refractions, lighting). In UIKit, it uses `UIGlassEffect` with `UIVisualEffectView`. Falls back to a translucent blur material on earlier iOS versions.

```swift
// UIKit — this is the default, no configuration needed
let dropDown = RSDropDown(frame: rect)

// SwiftUI — also the default
RSDropDownPicker(items: cities, selection: $selection, placeholder: "Pick a city")
    .frame(height: 44)
```

### Classic Apple

Opaque backgrounds, borders, shadows, and separators. Matches the traditional `UITableView` / `UITextField` appearance.

```swift
// UIKit
let dropDown = RSDropDown(frame: rect)
dropDown.configuration = .classic()

// SwiftUI
RSDropDownPicker(items: cities, selection: $selection, placeholder: "Pick a city")
    .classicStyle()
    .frame(height: 44)
```

### Switching Styles

You can switch between presets at any time:

```swift
// UIKit
dropDown.configuration = .liquidGlass()  // back to default
dropDown.configuration = .classic()

// SwiftUI
RSDropDownPicker(...)
    .glassStyle()    // back to default
    .classicStyle()
```

## Configuration

All configuration is grouped under `dropDown.configuration`:

```swift
dropDown.configuration.style.rowHeight = 56
dropDown.configuration.style.cornerRadius = 12
dropDown.configuration.list.maxHeight = 300
dropDown.configuration.chevron.size = 16
dropDown.configuration.behavior.hideOnSelect = false
dropDown.configuration.search.isEnabled = true
dropDown.configuration.animation.duration = 0.3
```

### Chainable API

```swift
let dropDown = RSDropDown(frame: rect)
    .rowHeight(56)
    .rowBackgroundColor(.systemBackground)
    .listMaxHeight(300)
    .searchEnabled(true)
```

### Configuration Reference

#### Style

| Property | Type | Default | Description |
|---|---|---|---|
| `rowHeight` | `CGFloat` | `44` | Row height (Apple standard) |
| `rowBackgroundColor` | `UIColor` | `.systemBackground` @ 45% | Row background color |
| `rowTextColor` | `UIColor` | `.label` | Text color |
| `selectedRowColor` | `UIColor` | `.systemFill` | Selected row highlight |
| `cellFont` | `UIFont` | `.body` (Dynamic Type) | Cell font |
| `cornerRadius` | `CGFloat` | `16` | Corner radius for dropdown and list |
| `usesGlassEffect` | `Bool` | `true` | Use Liquid Glass material |
| `showBorder` | `Bool` | `false` | Show border around the list |
| `showShadow` | `Bool` | `false` | Show shadow on the list |
| `showSeparators` | `Bool` | `false` | Show separators between rows |
| `borderColor` | `UIColor` | `.separator` | Border color |
| `borderWidth` | `CGFloat` | `0` | Border width (0 = hairline default) |
| `imageCellIsRounded` | `Bool` | `false` | Round cell images |

#### List

| Property | Type | Default | Description |
|---|---|---|---|
| `maxHeight` | `CGFloat` | `220` | Maximum list height (5 rows at 44pt) |
| `width` | `CGFloat?` | `nil` | Custom width (`nil` = match dropdown) |
| `spacing` | `CGFloat` | `4` | Spacing between dropdown and list |

#### Chevron

| Property | Type | Default | Description |
|---|---|---|---|
| `size` | `CGFloat` | `12` | Chevron image size |
| `color` | `UIColor` | `.secondaryLabel` | Chevron tint color |
| `image` | `UIImage` | `chevron.down` | Chevron SF Symbol |

#### Behavior

| Property | Type | Default | Description |
|---|---|---|---|
| `hideOnSelect` | `Bool` | `true` | Hide list after selection |
| `showCheckmark` | `Bool` | `true` | Show checkmark on selected row |
| `handleKeyboard` | `Bool` | `true` | Handle keyboard in search mode |
| `flashScrollIndicator` | `Bool` | `true` | Flash scroll indicators on open |
| `scrollToSelection` | `Bool` | `true` | Scroll to selected item on open |
| `hapticFeedback` | `Bool` | `true` | Haptic feedback on selection |

#### Search

| Property | Type | Default | Description |
|---|---|---|---|
| `isEnabled` | `Bool` | `false` | Enable search/autocomplete mode |
| `clearSelectionOnOpen` | `Bool` | `true` | Clear selection when search opens |

#### Animation

| Property | Type | Default | Description |
|---|---|---|---|
| `duration` | `TimeInterval` | `0.25` | Animation duration |

## Search / Autocomplete

When search is enabled, the dropdown becomes an editable text field that filters options as the user types.

```swift
// UIKit
dropDown.configuration.search.isEnabled = true
dropDown.configuration.search.clearSelectionOnOpen = true

// SwiftUI
RSDropDownPicker(items: countries, selection: $selection, placeholder: "Type to search...")
    .searchEnabled(true)
    .frame(height: 44)
```

## Custom Item Types

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

// UIKit
dropDown.setItems(countries)

// SwiftUI
RSDropDownPicker(items: countries, selection: $selection, placeholder: "Pick a country")
    .frame(height: 44)
```

`String` conforms to `DropDownItem` by default, so `[String]` arrays work everywhere.

## Callbacks

```swift
dropDown.onSelection = { selection in
    print(selection.item.dropDownTitle, selection.index)
}

dropDown.onDropDownWillAppear = { print("Will appear") }
dropDown.onDropDownDidAppear = { print("Did appear") }
dropDown.onDropDownWillDisappear = { print("Will disappear") }
dropDown.onDropDownDidDisappear = { print("Did disappear") }
```

## Programmatic Control

```swift
dropDown.showList()   // Open
dropDown.hideList()   // Close
dropDown.touchAction() // Toggle

dropDown.selectedIndex = 2
print(dropDown.selectedItemTitle)
print(dropDown.isDropDownOpen)
```

## SwiftUI Modifiers

`RSDropDownPicker` provides convenience modifiers that return a new picker with the updated configuration:

```swift
RSDropDownPicker(items: items, selection: $selection, placeholder: "Pick one")
    .classicStyle()                          // Apply classic preset
    .searchEnabled(true)                     // Enable search
    .dropDownConfiguration(customConfig)     // Apply a full custom config
    .frame(height: 44)
```

## Demo

An interactive demo is included in [`Sources/Demo/DemoView.swift`](Sources/Demo/DemoView.swift). It showcases both UIKit and SwiftUI usage with Liquid Glass, Classic, and custom configurations. Open the file in Xcode and use the Canvas preview (⌥⌘↩) to see it in action.

## Migration from v2

All v2 properties and methods are preserved with `@available(*, deprecated)` annotations. Existing code compiles with deprecation warnings only — no errors.

| v2 Property / Method | v3 Equivalent |
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

## License

RSDropDown is available under the MIT license.
