//
//  RSDropDownAnimator.swift
//  RSDropDown
//
//  Created by Radu Ursache (RanduSoft)
//

import UIKit

@MainActor
struct RSDropDownAnimator {
    var duration: TimeInterval

    // MARK: - Show

    func animateShow(
        tableView: UITableView,
        shadowView: UIView,
        chevronImageView: UIImageView,
        targetHeight: CGFloat,
        targetY: CGFloat,
        showShadow: Bool,
        willShowUp: Bool,
        dropDownOriginY: CGFloat,
        completion: @escaping @Sendable () -> Void
    ) {
        let isReduceMotion = UIAccessibility.isReduceMotionEnabled

        // Set the starting frame: collapsed height at the dropdown edge
        tableView.frame.size.height = 0
        tableView.alpha = 0

        if willShowUp {
            // Start collapsed at the bottom of where the list will appear
            tableView.frame.origin.y = dropDownOriginY
        } else {
            // Start collapsed at the top (just below the dropdown)
            tableView.frame.origin.y = targetY
        }

        shadowView.frame = tableView.frame
        shadowView.alpha = 0

        if isReduceMotion {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear) {
                self.applyShowTransform(
                    tableView: tableView,
                    shadowView: shadowView,
                    chevronImageView: chevronImageView,
                    targetHeight: targetHeight,
                    targetY: targetY,
                    showShadow: showShadow
                )
            } completion: { _ in
                completion()
            }
        } else {
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
                self.applyShowTransform(
                    tableView: tableView,
                    shadowView: shadowView,
                    chevronImageView: chevronImageView,
                    targetHeight: targetHeight,
                    targetY: targetY,
                    showShadow: showShadow
                )
            } completion: { _ in
                completion()
            }
        }
    }

    private func applyShowTransform(
        tableView: UITableView,
        shadowView: UIView,
        chevronImageView: UIImageView,
        targetHeight: CGFloat,
        targetY: CGFloat,
        showShadow: Bool
    ) {
        tableView.frame.origin.y = targetY
        tableView.frame.size.height = targetHeight
        tableView.alpha = 1

        shadowView.frame = tableView.frame
        if showShadow {
            shadowView.alpha = 1
        }

        chevronImageView.transform = CGAffineTransform(rotationAngle: .pi)
    }

    // MARK: - Hide

    func animateHide(
        tableView: UITableView,
        shadowView: UIView,
        chevronImageView: UIImageView,
        collapseToY: CGFloat,
        collapseWidth: CGFloat,
        collapseX: CGFloat,
        completion: @escaping @Sendable () -> Void
    ) {
        let isReduceMotion = UIAccessibility.isReduceMotionEnabled

        if isReduceMotion {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear) {
                self.applyHideTransform(
                    tableView: tableView,
                    shadowView: shadowView,
                    chevronImageView: chevronImageView,
                    collapseToY: collapseToY,
                    collapseWidth: collapseWidth,
                    collapseX: collapseX
                )
            } completion: { _ in
                completion()
            }
        } else {
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
                self.applyHideTransform(
                    tableView: tableView,
                    shadowView: shadowView,
                    chevronImageView: chevronImageView,
                    collapseToY: collapseToY,
                    collapseWidth: collapseWidth,
                    collapseX: collapseX
                )
            } completion: { _ in
                completion()
            }
        }
    }

    private func applyHideTransform(
        tableView: UITableView,
        shadowView: UIView,
        chevronImageView: UIImageView,
        collapseToY: CGFloat,
        collapseWidth: CGFloat,
        collapseX: CGFloat
    ) {
        tableView.frame = CGRect(x: collapseX, y: collapseToY, width: collapseWidth, height: 0)
        shadowView.alpha = 0
        shadowView.frame = tableView.frame
        chevronImageView.transform = .identity
    }
}
