//
//  Example.swift
//  RSDropDown
//
//  Created by Radu Ursache (RanduSoft)
//

import UIKit
import SwiftUI
import RSDropDown

// MARK: - v3 API (UIKit)

fileprivate final class DropDownExampleVC: UIViewController {

    private var dropDown: RSDropDown!

    override func viewDidLoad() {
        super.viewDidLoad()

        dropDown = RSDropDown(frame: CGRect(x: 20, y: 100, width: 300, height: 44))
        view.addSubview(dropDown)

        // Configuration (v3 grouped API)
        dropDown.configuration.style.rowHeight = 45
        dropDown.configuration.style.rowBackgroundColor = .systemBackground
        dropDown.configuration.style.cellFont = .systemFont(ofSize: 15, weight: .medium)
        dropDown.configuration.style.cornerRadius = 10
        dropDown.configuration.style.showBorder = true

        dropDown.configuration.chevron.size = 20
        dropDown.configuration.chevron.color = .systemRed

        dropDown.configuration.list.spacing = 10
        dropDown.configuration.list.maxHeight = 45 * 4 // 4 items visible

        // Data
        dropDown.placeholder = "Pick one"
        dropDown.optionArray = (1...500).compactMap { "Option \($0)" }

        // Selection callback (v3)
        dropDown.onSelection = { selection in
            print("Selected: \(selection.item.dropDownTitle) at index \(selection.index)")
        }

        // Or use the chainable API:
        // dropDown
        //     .rowHeight(45)
        //     .rowBackgroundColor(.systemBackground)
        //     .listMaxHeight(180)
        //     .searchEnabled(false)

        dropDown.selectedIndex = 2
    }
}

// MARK: - v3 API (SwiftUI)

fileprivate struct DropDownExampleSwiftUI: View {
    @State private var selection: String?

    var body: some View {
        VStack(spacing: 20) {
            RSDropDownPicker(
                items: ["Option 1", "Option 2", "Option 3", "Option 4", "Option 5"],
                selection: $selection,
                placeholder: "Pick one"
            )
            .frame(height: 44)

            if let selection {
                Text("Selected: \(selection)")
            }
        }
        .padding()
    }
}

// MARK: - v2 API (still works, produces deprecation warnings)

fileprivate final class LegacyDropDownExampleVC: UIViewController {
    @IBOutlet private weak var dropDown: RSDropDown!

    override func viewDidLoad() {
        super.viewDidLoad()

        dropDown.borderStyle = .none
        dropDown.backgroundColor = .systemBackground
        dropDown.textColor = .label
        dropDown.borderColor = .systemGreen
        dropDown.borderWidth = 1
        dropDown.rowBackgroundColor = .systemBackground
        dropDown.font = .systemFont(ofSize: 15, weight: .medium)
        dropDown.tableViewCellFont = .systemFont(ofSize: 15, weight: .medium)
        dropDown.tableViewCornerRadius = 8
        dropDown.chevronSize = 20
        dropDown.chevronColor = .systemRed
        dropDown.showTableViewBorder = true
        dropDown.padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        dropDown.isSearchEnabled = false
        dropDown.clearSearchSelectionOnOpen = false

        dropDown.listSpacing = 10
        dropDown.rowHeight = 45
        dropDown.listHeight = dropDown.rowHeight * 4

        dropDown.placeholder = "Pick one"
        dropDown.optionArray = (1...500).compactMap { "Option \($0)" }
        dropDown.didSelect { selectedItemText, selectedItemIndex, selectedItemId in
            print(selectedItemText, selectedItemIndex, selectedItemId)
        }

        dropDown.selectedIndex = 2
    }
}
