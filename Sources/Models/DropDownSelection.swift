//
//  DropDownSelection.swift
//  RSDropDown
//
//  Created by Radu Ursache (RanduSoft)
//

import Foundation

/// Represents a selection event from the dropdown.
public struct DropDownSelection: Sendable {
    /// The selected item.
    public let item: any DropDownItem

    /// The index of the selected item in the original (unfiltered) array.
    public let index: Int
}
