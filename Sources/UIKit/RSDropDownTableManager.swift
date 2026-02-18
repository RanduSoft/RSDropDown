//
//  RSDropDownTableManager.swift
//  RSDropDown
//
//  Created by Radu Ursache (RanduSoft)
//

import UIKit

final class RSDropDownTableManager: NSObject, UITableViewDataSource, UITableViewDelegate {

    // MARK: - State

    private(set) var allItems: [any DropDownItem] = []
    private(set) var filteredItems: [any DropDownItem] = []
    private(set) var imageArray: [String] = []

    var selectedIndex: Int?
    var style = DropDownConfiguration.Style()
    var showCheckmark: Bool = true
    var isSearchEnabled: Bool = false
    var currentSearchText: String = ""

    /// Called when the user taps a row. Provides (item, originalIndex).
    var onItemSelected: ((any DropDownItem, Int) -> Void)?

    /// Called when filtered data changes (for table resize).
    var onDataChanged: (() -> Void)?

    // MARK: - Data

    func setItems(_ items: [any DropDownItem]) {
        allItems = items
        applyFilter()
    }

    func setImageArray(_ images: [String]) {
        imageArray = images
    }

    func filterItems(with searchText: String) {
        currentSearchText = searchText
        applyFilter()
    }

    private func applyFilter() {
        if currentSearchText.isEmpty {
            filteredItems = allItems
        } else {
            filteredItems = allItems.filter {
                $0.dropDownTitle.range(of: currentSearchText, options: .caseInsensitive) != nil
            }
        }
        onDataChanged?()
    }

    func resetFilter() {
        currentSearchText = ""
        filteredItems = allItems
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RSDropDownCell.reuseIdentifier, for: indexPath) as? RSDropDownCell else {
            return UITableViewCell()
        }

        let item = filteredItems[indexPath.row]

        let isMatchingRow: Bool
        if isSearchEnabled {
            isMatchingRow = item.dropDownTitle.lowercased() == currentSearchText.lowercased()
        } else {
            // Map filtered index to original index for selection check
            let originalIndex = allItems.firstIndex(where: { $0.dropDownID == item.dropDownID })
            isMatchingRow = originalIndex == selectedIndex
        }

        cell.configure(with: item, style: style, isSelected: isMatchingRow, showCheckmark: showCheckmark)
        cell.hidesSeparator(indexPath.row == filteredItems.count - 1)

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = filteredItems[indexPath.row]

        // Flash the cell
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.alpha = 0
            UIView.animate(withDuration: 0.2) {
                cell.alpha = 1
                cell.backgroundColor = self.style.selectedRowColor
            }
        }

        // Find the original index in the unfiltered array
        if let originalIndex = allItems.firstIndex(where: { $0.dropDownID == item.dropDownID }) {
            onItemSelected?(item, originalIndex)
        }
    }
}
