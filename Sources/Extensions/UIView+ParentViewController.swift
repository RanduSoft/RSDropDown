//
//  UIView+ParentViewController.swift
//  RSDropDown
//
//  Created by Radu Ursache (RanduSoft)
//

import UIKit

extension UIView {
    /// Walks the responder chain to find the nearest parent `UIViewController`.
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let viewController = next as? UIViewController {
                return viewController
            }
            responder = next
        }
        return nil
    }
}
