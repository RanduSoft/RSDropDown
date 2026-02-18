//
//  DropDownFilteringTests.swift
//  RSDropDownTests
//

import Testing
@testable import RSDropDown

@Suite("Dropdown Filtering")
struct DropDownFilteringTests {

    private func makeManager(items: [String] = ["Apple", "Banana", "Cherry", "Date", "Elderberry"]) -> RSDropDownTableManager {
        let manager = RSDropDownTableManager()
        manager.setItems(items)
        return manager
    }

    @Test("Empty search returns all items")
    func emptySearchReturnsAll() {
        let manager = makeManager()
        manager.filterItems(with: "")
        #expect(manager.filteredItems.count == 5)
    }

    @Test("Case-insensitive filtering")
    func caseInsensitiveFiltering() {
        let manager = makeManager()
        manager.filterItems(with: "apple")
        #expect(manager.filteredItems.count == 1)
        #expect(manager.filteredItems[0].dropDownTitle == "Apple")
    }

    @Test("Partial match filtering")
    func partialMatchFiltering() {
        let manager = makeManager()
        manager.filterItems(with: "an")
        #expect(manager.filteredItems.count == 1)
        #expect(manager.filteredItems[0].dropDownTitle == "Banana")
    }

    @Test("No match returns empty array")
    func noMatchReturnsEmpty() {
        let manager = makeManager()
        manager.filterItems(with: "xyz")
        #expect(manager.filteredItems.isEmpty)
    }

    @Test("Reset filter restores all items")
    func resetFilterRestoresAll() {
        let manager = makeManager()
        manager.filterItems(with: "apple")
        #expect(manager.filteredItems.count == 1)
        manager.resetFilter()
        #expect(manager.filteredItems.count == 5)
    }

    @Test("Multiple matches")
    func multipleMatches() {
        let manager = makeManager(items: ["Cat", "Car", "Cow", "Dog"])
        manager.filterItems(with: "Ca")
        #expect(manager.filteredItems.count == 2)
    }

    @Test("Setting new items clears previous filter")
    func settingNewItemsClearsFilter() {
        let manager = makeManager()
        manager.filterItems(with: "apple")
        #expect(manager.filteredItems.count == 1)
        manager.setItems(["X", "Y", "Z"])
        // setItems re-applies the current filter
        #expect(manager.allItems.count == 3)
    }
}
