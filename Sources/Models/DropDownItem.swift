//
//  DropDownItem.swift
//  RSDropDown
//
//  Created by Radu Ursache (RanduSoft)
//

import Foundation

/// Protocol that any dropdown item must conform to.
public protocol DropDownItem: Sendable {
    /// The text displayed in the dropdown row.
    var dropDownTitle: String { get }

    /// Optional image name (from asset catalog) displayed in the row.
    var dropDownImage: String? { get }

    /// Unique identifier used for equality checks and selection tracking.
    var dropDownID: AnyHashable { get }
}

public extension DropDownItem {
    var dropDownImage: String? { nil }
    var dropDownID: AnyHashable { dropDownTitle }
}

extension String: DropDownItem {
    public var dropDownTitle: String { self }
    public var dropDownImage: String? { nil }
    public var dropDownID: AnyHashable { self }
}
