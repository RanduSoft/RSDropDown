//
//  DropDownRepresentable.swift
//  RSDropDown
//
//  Created by Radu Ursache (RanduSoft)
//

import SwiftUI

/// A SwiftUI wrapper around `RSDropDown`.
///
/// On iOS 26+, glass mode uses the native `.glassEffect()` modifier for
/// full Liquid Glass rendering (reflections, refractions, lighting).
/// On earlier versions, a `.thinMaterial` blur provides a translucent fallback.
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
public struct RSDropDownPicker<Item: DropDownItem & Equatable>: View {
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

    public var body: some View {
        _RSDropDownRepresentable(
            items: items,
            selection: $selection,
            placeholder: placeholder,
            configuration: configuration,
            externalGlass: configuration.style.usesGlassEffect
        )
        .modifier(_GlassModifier(
            isEnabled: configuration.style.usesGlassEffect,
            cornerRadius: configuration.style.cornerRadius
        ))
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

    /// Applies the Liquid Glass style (iOS 26+ native glass, translucent blur fallback on earlier).
    /// This is the default style, so calling this is only needed to reset after other modifications.
    public func glassStyle() -> RSDropDownPicker {
        var copy = self
        copy.configuration = .liquidGlass()
        return copy
    }

    /// Applies the Classic Apple style (opaque backgrounds, borders, shadows, separators).
    public func classicStyle() -> RSDropDownPicker {
        var copy = self
        copy.configuration = .classic()
        return copy
    }
}

// MARK: - Glass ViewModifier

/// Conditionally applies the native `.glassEffect()` modifier (iOS 26+)
/// or a `.thinMaterial` background (earlier iOS).
private struct _GlassModifier: ViewModifier {
    let isEnabled: Bool
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if isEnabled {
            if #available(iOS 26, *) {
                content
                    .glassEffect(in: .rect(cornerRadius: cornerRadius))
            } else {
                content
                    .background(
                        .thinMaterial,
                        in: RoundedRectangle(cornerRadius: cornerRadius)
                    )
            }
        } else {
            content
        }
    }
}

// MARK: - Internal UIViewRepresentable

/// Bridges `RSDropDown` (UIKit) into SwiftUI.
/// When `externalGlass` is true, the UIKit view skips its own glass background
/// so the SwiftUI `.glassEffect()` modifier can handle it instead.
private struct _RSDropDownRepresentable<Item: DropDownItem & Equatable>: UIViewRepresentable {
    let items: [Item]
    @Binding var selection: Item?
    var placeholder: String?
    var configuration: DropDownConfiguration
    var externalGlass: Bool

    func makeUIView(context: Context) -> RSDropDown {
        let dropdown = RSDropDown(frame: .zero)
        dropdown.placeholder = placeholder
        dropdown.externalGlassEffect = externalGlass
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

    func updateUIView(_ uiView: RSDropDown, context: Context) {
        // Don't interfere while the dropdown is open or animating closed —
        // setItems/configuration changes trigger resizeTable and reloadData
        // which fight the ongoing hide animation and cause flicker.
        guard !uiView.isDropDownOpen else { return }

        uiView.setItems(items)
        uiView.externalGlassEffect = externalGlass
        uiView.configuration = configuration
        if let selected = selection,
           let index = items.firstIndex(where: { $0 == selected }) {
            uiView.selectedIndex = index
        } else {
            uiView.selectedIndex = nil
        }
    }
}
