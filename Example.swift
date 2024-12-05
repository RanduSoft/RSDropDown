//
//  Example.swift
//  RSDropDown
//
//  Created by Radu Ursache
//

import UIKit
import RSDropDown

fileprivate final class DropDownExampleVC: UIViewController {
    @IBOutlet private weak var dropDown: RSDropDown! // add a new UITextField in Storyboard then set its class to RSDropDown
    
    func viewDidLoad() {
        super.viewDidLoad()
        
        // if you don't use storyboards..
//        self.dropDown = RSDropDown(frame: CGRect(origin: CGPoint(x: 20, y: 40), size: CGSize(width: 100, height: 150)))
        
        // customization
        self.dropDown.borderStyle = .none
        self.dropDown.backgroundColor = .systemBackground
        self.dropDown.textColor = .label
        self.dropDown.borderColor = .systemGreen
        self.dropDown.borderWidth = 1
        self.dropDown.rowBackgroundColor = .systemBackground
        self.dropDown.font = .systemFont(ofSize: 15, weight: .medium)
        self.dropDown.tableViewCellFont = .systemFont(ofSize: 15, weight: .medium)
        self.dropDown.tableViewCornerRadius = 8
        self.dropDown.chevronSize = 20
        self.dropDown.chevronColor = .systemRed
        self.dropDown.showTableBorder = true
        self.dropDown.cornerRadius = 10
        self.dropDown.padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        self.dropDown.isSearchEnabled = false
        self.dropDown.clearSearchSelectionOnOpen = false
        
        // setup
//        self.dropDown.listWidth = 380
        self.dropDown.listSpacing = 10
        self.dropDown.rowHeight = 45
        self.dropDown.listHeight = self.dropDown.rowHeight * 4 // 4 items visible
        
        self.dropDown.optionArray = (1...500).compactMap { "Option \($0)" }
        self.dropDown.didSelect { selectedItemText, selectedItemIndex, selectedItemId in
            print(selectedItemText, selectedItemIndex, selectedItemId)
        }
        
        // optional setup
        self.dropDown.selectedIndex = 2 // default selected index
    }
}


