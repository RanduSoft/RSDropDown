//
//  RSDropDownAPITests.swift
//  RSDropDownTests
//

import Testing
import UIKit
@testable import RSDropDown

@Suite("RSDropDown API")
@MainActor
struct RSDropDownAPITests {

    @Test("Initialization with frame")
    func initWithFrame() {
        let dropdown = RSDropDown(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        #expect(dropdown.selectedIndex == nil)
        #expect(dropdown.selectedItemTitle == "")
    }

    @Test("Setting optionArray updates selection when no placeholder")
    func optionArrayAutoSelect() {
        let dropdown = RSDropDown(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        dropdown.optionArray = ["A", "B", "C"]
        #expect(dropdown.selectedIndex == 0)
        #expect(dropdown.text == "A")
    }

    @Test("Setting placeholder prevents auto-selection")
    func placeholderPreventsAutoSelect() {
        let dropdown = RSDropDown(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        dropdown.placeholder = "Choose..."
        dropdown.optionArray = ["A", "B", "C"]
        #expect(dropdown.selectedIndex == nil)
        #expect(dropdown.selectedItemTitle == "")
    }

    @Test("selectedIndex bounds validation")
    func selectedIndexBoundsCheck() {
        let dropdown = RSDropDown(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        dropdown.placeholder = "Pick"
        dropdown.optionArray = ["A", "B", "C"]
        dropdown.selectedIndex = 10  // Out of bounds
        #expect(dropdown.selectedIndex == nil)
        #expect(dropdown.selectedItemTitle == "")
    }

    @Test("selectedIndex negative value treated as nil")
    func selectedIndexNegative() {
        let dropdown = RSDropDown(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        dropdown.placeholder = "Pick"
        dropdown.optionArray = ["A", "B"]
        dropdown.selectedIndex = -1
        #expect(dropdown.selectedIndex == nil)
    }

    @Test("setItems works with strings")
    func setItemsWithStrings() {
        let dropdown = RSDropDown(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        dropdown.placeholder = "Pick"
        dropdown.setItems(["X", "Y", "Z"])
        dropdown.selectedIndex = 1
        #expect(dropdown.text == "Y")
    }

    @Test("Deprecated rowHeight forwards to configuration")
    func deprecatedRowHeight() {
        let dropdown = RSDropDown(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        dropdown.rowHeight = 60
        #expect(dropdown.configuration.style.rowHeight == 60)
    }

    @Test("Deprecated hideOptionsOnSelect forwards to configuration")
    func deprecatedHideOptionsOnSelect() {
        let dropdown = RSDropDown(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        dropdown.hideOptionsOnSelect = false
        #expect(dropdown.configuration.behavior.hideOnSelect == false)
    }

    @Test("Deprecated isSearchEnabled forwards to configuration")
    func deprecatedIsSearchEnabled() {
        let dropdown = RSDropDown(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        dropdown.isSearchEnabled = true
        #expect(dropdown.configuration.search.isEnabled == true)
    }

    @Test("Deprecated listHeight forwards to configuration")
    func deprecatedListHeight() {
        let dropdown = RSDropDown(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        dropdown.listHeight = 300
        #expect(dropdown.configuration.list.maxHeight == 300)
    }

    @Test("Deprecated listWidth forwards to configuration")
    func deprecatedListWidth() {
        let dropdown = RSDropDown(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        dropdown.listWidth = 250
        #expect(dropdown.configuration.list.width == 250)

        dropdown.listWidth = 0
        #expect(dropdown.configuration.list.width == nil)
    }

    @Test("Deprecated chevronSize forwards to configuration")
    func deprecatedChevronSize() {
        let dropdown = RSDropDown(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        dropdown.chevronSize = 20
        #expect(dropdown.configuration.chevron.size == 20)
    }

    @Test("Deprecated animationDuration forwards to configuration")
    func deprecatedAnimationDuration() {
        let dropdown = RSDropDown(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        dropdown.animationDuration = 0.5
        #expect(dropdown.configuration.animation.duration == 0.5)
    }

    @Test("Chainable API works")
    func chainableAPI() {
        let dropdown = RSDropDown(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
            .rowHeight(50)
            .rowBackgroundColor(.red)
            .listMaxHeight(300)
            .searchEnabled(true)

        #expect(dropdown.configuration.style.rowHeight == 50)
        #expect(dropdown.configuration.style.rowBackgroundColor == .red)
        #expect(dropdown.configuration.list.maxHeight == 300)
        #expect(dropdown.configuration.search.isEnabled == true)
    }

    @Test("DropDownSelection model contains correct data")
    func dropDownSelectionModel() {
        let selection = DropDownSelection(item: "Test", index: 2)
        #expect(selection.item.dropDownTitle == "Test")
        #expect(selection.index == 2)
    }
}
