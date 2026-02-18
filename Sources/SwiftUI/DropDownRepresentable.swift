//
//  DropDownRepresentable.swift
//  RSDropDown
//
//  Created by Radu Ursache (RanduSoft)
//

import SwiftUI

/// A SwiftUI wrapper around `RSDropDown`.
///
/// Usage:
/// ```swift
/// @State private var selection: String?
///
/// RSDropDownPicker(
///     items: ["Option 1", "Option 2", "Option 3"],
///     selection: $selection,
///     placeholder: "Pick one"
/// )
/// .frame(height: 44)
/// ```
public struct RSDropDownPicker<Item: DropDownItem & Equatable>: UIViewRepresentable {
    private let items: [Item]
    @Binding private var selection: Item?
    private var placeholder: String?
    private var configuration: DropDownConfiguration

    public init(
        items: [Item],
        selection: Binding<Item?>,
        placeholder: String? = nil,
        configuration: DropDownConfiguration = .init()
    ) {
        self.items = items
        self._selection = selection
        self.placeholder = placeholder
        self.configuration = configuration
    }

    public func makeUIView(context: Context) -> RSDropDown {
        let dropdown = RSDropDown(frame: .zero)
        dropdown.placeholder = placeholder
        dropdown.configuration = configuration
        dropdown.setItems(items)
        dropdown.onSelection = { dropDownSelection in
            DispatchQueue.main.async {
                if let selected = dropDownSelection.item as? Item {
                    self.selection = selected
                }
            }
        }
        return dropdown
    }

    public func updateUIView(_ uiView: RSDropDown, context: Context) {
        // Don't interfere while the dropdown is open or animating closed —
        // setItems/configuration changes trigger resizeTable and reloadData
        // which fight the ongoing hide animation and cause flicker.
        guard !uiView.isDropDownOpen else { return }

        uiView.setItems(items)
        uiView.configuration = configuration
        if let selected = selection,
           let index = items.firstIndex(where: { $0 == selected }) {
            uiView.selectedIndex = index
        } else {
            uiView.selectedIndex = nil
        }
    }

    // MARK: - Modifiers

    /// Applies a custom configuration to the dropdown.
    public func dropDownConfiguration(_ config: DropDownConfiguration) -> RSDropDownPicker {
        var copy = self
        copy.configuration = config
        return copy
    }

    /// Enables or disables search mode.
    public func searchEnabled(_ enabled: Bool) -> RSDropDownPicker {
        var copy = self
        copy.configuration.search.isEnabled = enabled
        return copy
    }

    /// Applies the Liquid Glass style (iOS 26+ glass material, translucent blur fallback on earlier).
    public func glassStyle() -> RSDropDownPicker {
        var copy = self
        copy.configuration = .liquidGlass()
        return copy
    }
}
