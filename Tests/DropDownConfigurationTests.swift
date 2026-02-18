//
//  DropDownConfigurationTests.swift
//  RSDropDownTests
//

import Testing
@testable import RSDropDown

@Suite("DropDownConfiguration")
struct DropDownConfigurationTests {

    @Test("Default style values match Apple HIG")
    func defaultStyleValues() {
        let config = DropDownConfiguration()
        #expect(config.style.rowHeight == 44)
        #expect(config.style.cornerRadius == 10)
        #expect(config.style.showBorder == true)
        #expect(config.style.showShadow == true)
        #expect(config.style.borderWidth == 0)
        #expect(config.style.imageCellIsRounded == false)
    }

    @Test("Default list values")
    func defaultListValues() {
        let config = DropDownConfiguration()
        #expect(config.list.maxHeight == 220)
        #expect(config.list.width == nil)
        #expect(config.list.spacing == 4)
    }

    @Test("Default chevron values")
    func defaultChevronValues() {
        let config = DropDownConfiguration()
        #expect(config.chevron.size == 12)
    }

    @Test("Default behavior values")
    func defaultBehaviorValues() {
        let config = DropDownConfiguration()
        #expect(config.behavior.hideOnSelect == true)
        #expect(config.behavior.showCheckmark == true)
        #expect(config.behavior.handleKeyboard == true)
        #expect(config.behavior.flashScrollIndicator == true)
        #expect(config.behavior.scrollToSelection == true)
        #expect(config.behavior.hapticFeedback == true)
    }

    @Test("Default search values")
    func defaultSearchValues() {
        let config = DropDownConfiguration()
        #expect(config.search.isEnabled == false)
        #expect(config.search.clearSelectionOnOpen == true)
    }

    @Test("Default animation duration matches Apple standard")
    func defaultAnimationDuration() {
        let config = DropDownConfiguration()
        #expect(config.animation.duration == 0.25)
    }

    @Test("Mutation of nested structs works correctly")
    func nestedStructMutation() {
        var config = DropDownConfiguration()
        config.style.rowHeight = 60
        config.list.maxHeight = 300
        config.chevron.size = 20
        config.behavior.hideOnSelect = false
        config.search.isEnabled = true
        config.animation.duration = 0.5

        #expect(config.style.rowHeight == 60)
        #expect(config.list.maxHeight == 300)
        #expect(config.chevron.size == 20)
        #expect(config.behavior.hideOnSelect == false)
        #expect(config.search.isEnabled == true)
        #expect(config.animation.duration == 0.5)
    }
}
