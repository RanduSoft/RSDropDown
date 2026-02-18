//
//  DropDownConfigurationTests.swift
//  RSDropDownTests
//

import Testing
@testable import RSDropDown

@Suite("DropDownConfiguration")
struct DropDownConfigurationTests {

    @Test("Default style values use Liquid Glass")
    func defaultStyleValues() {
        let config = DropDownConfiguration()
        #expect(config.style.rowHeight == 44)
        #expect(config.style.cornerRadius == 16)
        #expect(config.style.showBorder == false)
        #expect(config.style.showShadow == false)
        #expect(config.style.showSeparators == false)
        #expect(config.style.usesGlassEffect == true)
        #expect(config.style.borderWidth == 0)
        #expect(config.style.imageCellIsRounded == false)
    }

    @Test("Classic preset restores opaque bordered style")
    func classicPresetValues() {
        let config = DropDownConfiguration.classic()
        #expect(config.style.usesGlassEffect == false)
        #expect(config.style.showBorder == true)
        #expect(config.style.showShadow == true)
        #expect(config.style.showSeparators == true)
        #expect(config.style.cornerRadius == 10)
        #expect(config.style.rowBackgroundColor == .systemBackground)
        #expect(config.style.borderColor == .opaqueSeparator)
    }

    @Test("liquidGlass() is equivalent to default init")
    func liquidGlassPresetMatchesDefault() {
        let defaultConfig = DropDownConfiguration()
        let glassConfig = DropDownConfiguration.liquidGlass()
        #expect(defaultConfig.style.usesGlassEffect == glassConfig.style.usesGlassEffect)
        #expect(defaultConfig.style.showBorder == glassConfig.style.showBorder)
        #expect(defaultConfig.style.cornerRadius == glassConfig.style.cornerRadius)
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
