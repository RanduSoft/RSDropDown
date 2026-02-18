//
//  DropDownItemTests.swift
//  RSDropDownTests
//

import Testing
@testable import RSDropDown

@Suite("DropDownItem")
struct DropDownItemTests {

    @Test("String conforms to DropDownItem")
    func stringConformance() {
        let item: any DropDownItem = "Hello"
        #expect(item.dropDownTitle == "Hello")
        #expect(item.dropDownImage == nil)
        #expect(item.dropDownID == AnyHashable("Hello"))
    }

    @Test("String array works as DropDownItem array")
    func stringArrayConformance() {
        let items: [any DropDownItem] = ["A", "B", "C"]
        #expect(items.count == 3)
        #expect(items[0].dropDownTitle == "A")
        #expect(items[1].dropDownTitle == "B")
        #expect(items[2].dropDownTitle == "C")
    }

    @Test("Custom struct conforms to DropDownItem")
    func customStructConformance() {
        struct Country: DropDownItem {
            let name: String
            let code: String
            var dropDownTitle: String { name }
            var dropDownID: AnyHashable { code }
        }

        let item = Country(name: "Romania", code: "RO")
        #expect(item.dropDownTitle == "Romania")
        #expect(item.dropDownImage == nil)
        #expect(item.dropDownID == AnyHashable("RO"))
    }

    @Test("Custom struct with image")
    func customStructWithImage() {
        struct MenuItem: DropDownItem {
            let title: String
            let icon: String
            var dropDownTitle: String { title }
            var dropDownImage: String? { icon }
        }

        let item = MenuItem(title: "Settings", icon: "gear")
        #expect(item.dropDownTitle == "Settings")
        #expect(item.dropDownImage == "gear")
    }

    @Test("Default dropDownID uses title")
    func defaultIdUsesTitle() {
        struct SimpleItem: DropDownItem {
            let dropDownTitle: String
        }

        let item = SimpleItem(dropDownTitle: "Test")
        #expect(item.dropDownID == AnyHashable("Test"))
    }
}
