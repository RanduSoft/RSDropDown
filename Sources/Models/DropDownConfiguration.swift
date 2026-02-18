//
//  DropDownConfiguration.swift
//  RSDropDown
//
//  Created by Radu Ursache (RanduSoft)
//

import UIKit

/// Grouped configuration for RSDropDown appearance and behavior.
///
/// All defaults are aligned with Apple's Human Interface Guidelines
/// and system component conventions.
public struct DropDownConfiguration {
    public var style = Style()
    public var list = List()
    public var chevron = Chevron()
    public var behavior = Behavior()
    public var search = Search()
    public var animation = Animation()

    public init() {}

    // MARK: - Style

    public struct Style {
        /// Apple standard `UITableView` row height (44pt).
        public var rowHeight: CGFloat = 44

        /// Row background color.
        public var rowBackgroundColor: UIColor = .systemBackground.withAlphaComponent(0.45)

        /// System label color.
        public var rowTextColor: UIColor = .label

        /// System fill color for selection highlight.
        public var selectedRowColor: UIColor = .systemFill

        /// Dynamic Type body font (17pt at default size, scales with accessibility).
        public var cellFont: UIFont = .preferredFont(forTextStyle: .body)

        /// Whether to show a border around the dropdown list.
        public var showBorder: Bool = false

        /// Subtle system shadow on the floating list.
        public var showShadow: Bool = false

        /// System separator color for borders.
        public var borderColor: UIColor = .separator

        /// Border width (used when `showBorder` is true; 0 = use default 0.5pt).
        public var borderWidth: CGFloat = 0

        /// Corner radius for the dropdown and list.
        public var cornerRadius: CGFloat = 16

        /// Whether cell images use rounded corners.
        public var imageCellIsRounded: Bool = false

        /// Show separators between rows in the list.
        public var showSeparators: Bool = false

        /// Applies Liquid Glass material (iOS 26+) or translucent blur (earlier) to the dropdown and list.
        public var usesGlassEffect: Bool = true
    }

    // MARK: - List

    public struct List {
        /// 5 rows visible at standard 44pt height.
        public var maxHeight: CGFloat = 220

        /// Custom list width. `nil` matches the dropdown width.
        public var width: CGFloat? = nil

        /// Spacing between the dropdown and the list.
        public var spacing: CGFloat = 4
    }

    // MARK: - Chevron

    public struct Chevron {
        /// SF Symbols default accessory size.
        public var size: CGFloat = 12

        /// Secondary label color, matching system disclosure indicators.
        public var color: UIColor = .secondaryLabel

        /// The chevron image.
        public var image: UIImage = UIImage(systemName: "chevron.down") ?? UIImage()
    }

    // MARK: - Behavior

    public struct Behavior {
        /// Automatically hide the dropdown after an item is selected.
        public var hideOnSelect: Bool = true

        /// Show a checkmark accessory on the selected row.
        public var showCheckmark: Bool = true

        /// Dismiss the keyboard when the dropdown opens (search mode).
        public var handleKeyboard: Bool = true

        /// Flash scroll indicators when the list appears.
        public var flashScrollIndicator: Bool = true

        /// Scroll to the currently selected item when the list opens.
        public var scrollToSelection: Bool = true

        /// Light haptic feedback on selection.
        public var hapticFeedback: Bool = true
    }

    // MARK: - Search

    public struct Search {
        /// Enable search/autocomplete mode (text field becomes editable).
        public var isEnabled: Bool = false

        /// Clear the current selection when the dropdown opens in search mode.
        public var clearSelectionOnOpen: Bool = true
    }

    // MARK: - Animation

    public struct Animation {
        /// Apple standard animation duration (0.25s).
        public var duration: TimeInterval = 0.25
    }
}

// MARK: - Presets

extension DropDownConfiguration {
    /// The default Liquid Glass style. Equivalent to `DropDownConfiguration()`.
    ///
    /// Uses glass material on iOS 26+ with a translucent blur fallback on earlier versions.
    public static func liquidGlass() -> DropDownConfiguration {
        DropDownConfiguration()
    }

    /// Classic Apple style with opaque backgrounds, borders, shadows, and separators.
    ///
    /// This matches the traditional `UITableView` / `UITextField` appearance.
    public static func classic() -> DropDownConfiguration {
        var config = DropDownConfiguration()
        config.style.usesGlassEffect = false
        config.style.showBorder = true
        config.style.showShadow = true
        config.style.rowBackgroundColor = .systemBackground
        config.style.borderColor = .opaqueSeparator
        config.style.showSeparators = true
        config.style.cornerRadius = 10
        return config
    }
}
