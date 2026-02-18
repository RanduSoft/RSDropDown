//
//  RSDropDownDeprecations.swift
//  RSDropDown
//
//  Created by Radu Ursache (RanduSoft)
//
//  Backward-compatible shims for the v2 API.
//  Every v2 public property and method is preserved here with deprecation annotations.
//

import UIKit

extension RSDropDown {

    // MARK: - Style

    @available(*, deprecated, renamed: "configuration.style.rowHeight")
    @IBInspectable public var rowHeight: CGFloat {
        get { configuration.style.rowHeight }
        set { configuration.style.rowHeight = newValue }
    }

    @available(*, deprecated, renamed: "configuration.style.rowBackgroundColor")
    @IBInspectable public var rowBackgroundColor: UIColor {
        get { configuration.style.rowBackgroundColor }
        set { configuration.style.rowBackgroundColor = newValue }
    }

    @available(*, deprecated, renamed: "configuration.style.rowTextColor")
    @IBInspectable public var rowTextColor: UIColor {
        get { configuration.style.rowTextColor }
        set { configuration.style.rowTextColor = newValue }
    }

    @available(*, deprecated, renamed: "configuration.style.selectedRowColor")
    @IBInspectable public var selectedRowColor: UIColor {
        get { configuration.style.selectedRowColor }
        set { configuration.style.selectedRowColor = newValue }
    }

    @available(*, deprecated, renamed: "configuration.style.cellFont")
    @IBInspectable public var tableViewCellFont: UIFont {
        get { configuration.style.cellFont }
        set { configuration.style.cellFont = newValue }
    }

    @available(*, deprecated, renamed: "configuration.style.showBorder")
    @IBInspectable public var showTableViewBorder: Bool {
        get { configuration.style.showBorder }
        set { configuration.style.showBorder = newValue }
    }

    /// Alias used in some v2 example code (`showTableBorder` instead of `showTableViewBorder`).
    @available(*, deprecated, renamed: "configuration.style.showBorder")
    @IBInspectable public var showTableBorder: Bool {
        get { configuration.style.showBorder }
        set { configuration.style.showBorder = newValue }
    }

    @available(*, deprecated, renamed: "configuration.style.showShadow")
    @IBInspectable public var showTableViewShadow: Bool {
        get { configuration.style.showShadow }
        set { configuration.style.showShadow = newValue }
    }

    @available(*, deprecated, renamed: "configuration.style.cornerRadius")
    @IBInspectable public var tableViewCornerRadius: CGFloat {
        get { configuration.style.cornerRadius }
        set { configuration.style.cornerRadius = newValue }
    }

    @available(*, deprecated, renamed: "configuration.style.imageCellIsRounded")
    @IBInspectable public var imageCellIsRounded: Bool {
        get { configuration.style.imageCellIsRounded }
        set { configuration.style.imageCellIsRounded = newValue }
    }

    @available(*, deprecated, renamed: "configuration.style.borderColor")
    @IBInspectable public var borderColor: UIColor {
        get { configuration.style.borderColor }
        set {
            configuration.style.borderColor = newValue
            layer.borderColor = newValue.cgColor
        }
    }

    @available(*, deprecated, renamed: "configuration.style.borderWidth")
    @IBInspectable public var borderWidth: CGFloat {
        get { configuration.style.borderWidth }
        set {
            configuration.style.borderWidth = newValue
            layer.borderWidth = newValue
        }
    }

    // MARK: - List

    @available(*, deprecated, renamed: "configuration.list.maxHeight")
    @IBInspectable public var listHeight: CGFloat {
        get { configuration.list.maxHeight }
        set { configuration.list.maxHeight = newValue }
    }

    @available(*, deprecated, renamed: "configuration.list.width")
    @IBInspectable public var listWidth: CGFloat {
        get { configuration.list.width ?? 0 }
        set { configuration.list.width = newValue == 0 ? nil : newValue }
    }

    @available(*, deprecated, renamed: "configuration.list.spacing")
    @IBInspectable public var listSpacing: CGFloat {
        get { configuration.list.spacing }
        set { configuration.list.spacing = newValue }
    }

    // MARK: - Chevron

    @available(*, deprecated, renamed: "configuration.chevron.size")
    @IBInspectable public var chevronSize: CGFloat {
        get { configuration.chevron.size }
        set { configuration.chevron.size = newValue }
    }

    @available(*, deprecated, renamed: "configuration.chevron.color")
    @IBInspectable public var chevronColor: UIColor {
        get { configuration.chevron.color }
        set { configuration.chevron.color = newValue }
    }

    @available(*, deprecated, renamed: "configuration.chevron.image")
    @IBInspectable public var chevronImage: UIImage {
        get { configuration.chevron.image }
        set { configuration.chevron.image = newValue }
    }

    // MARK: - Behavior

    @available(*, deprecated, renamed: "configuration.behavior.hideOnSelect")
    @IBInspectable public var hideOptionsOnSelect: Bool {
        get { configuration.behavior.hideOnSelect }
        set { configuration.behavior.hideOnSelect = newValue }
    }

    @available(*, deprecated, renamed: "configuration.behavior.showCheckmark")
    @IBInspectable public var checkMarkEnabled: Bool {
        get { configuration.behavior.showCheckmark }
        set { configuration.behavior.showCheckmark = newValue }
    }

    @available(*, deprecated, renamed: "configuration.behavior.handleKeyboard")
    @IBInspectable public var handleKeyboard: Bool {
        get { configuration.behavior.handleKeyboard }
        set { configuration.behavior.handleKeyboard = newValue }
    }

    @available(*, deprecated, renamed: "configuration.behavior.flashScrollIndicator")
    @IBInspectable public var flashIndicatorWhenOpeningList: Bool {
        get { configuration.behavior.flashScrollIndicator }
        set { configuration.behavior.flashScrollIndicator = newValue }
    }

    @available(*, deprecated, renamed: "configuration.behavior.scrollToSelection")
    @IBInspectable public var scrollToSelectedItem: Bool {
        get { configuration.behavior.scrollToSelection }
        set { configuration.behavior.scrollToSelection = newValue }
    }

    // MARK: - Search

    @available(*, deprecated, renamed: "configuration.search.isEnabled")
    @IBInspectable public var isSearchEnabled: Bool {
        get { configuration.search.isEnabled }
        set { configuration.search.isEnabled = newValue }
    }

    @available(*, deprecated, renamed: "configuration.search.clearSelectionOnOpen")
    @IBInspectable public var clearSearchSelectionOnOpen: Bool {
        get { configuration.search.clearSelectionOnOpen }
        set { configuration.search.clearSelectionOnOpen = newValue }
    }

    // MARK: - Animation

    @available(*, deprecated, renamed: "configuration.animation.duration")
    @IBInspectable public var animationDuration: TimeInterval {
        get { configuration.animation.duration }
        set { configuration.animation.duration = newValue }
    }

    // MARK: - Image & ID arrays (deprecated in favor of DropDownItem)

    @available(*, deprecated, message: "Use DropDownItem.dropDownImage instead")
    public var optionImageArray: [String] {
        get { [] }
        set { /* no-op: images are now part of DropDownItem */ }
    }

    @available(*, deprecated, message: "Use DropDownItem.dropDownID instead")
    public var optionIds: [Int]? {
        get { nil }
        set { /* no-op: IDs are now part of DropDownItem */ }
    }

    // MARK: - Callback methods (deprecated in favor of closure properties)

    @available(*, deprecated, message: "Use onSelection closure instead")
    public func didSelect(completion: @escaping (_ selectedText: String, _ index: Int, _ id: Int) -> Void) {
        legacyDidSelectCompletion = completion
    }

    @available(*, deprecated, renamed: "onDropDownWillAppear")
    public func listWillAppear(completion: @escaping () -> Void) {
        legacyTableViewWillAppearHandler = completion
    }

    @available(*, deprecated, renamed: "onDropDownDidAppear")
    public func listDidAppear(completion: @escaping () -> Void) {
        legacyTableViewDidAppearHandler = completion
    }

    @available(*, deprecated, renamed: "onDropDownWillDisappear")
    public func listWillDisappear(completion: @escaping () -> Void) {
        legacyTableViewWillDisappearHandler = completion
    }

    @available(*, deprecated, renamed: "onDropDownDidDisappear")
    public func listDidDisappear(completion: @escaping () -> Void) {
        legacyTableViewDidDisappearHandler = completion
    }
}
