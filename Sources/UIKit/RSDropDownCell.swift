//
//  RSDropDownCell.swift
//  RSDropDown
//
//  Created by Radu Ursache (RanduSoft)
//

import UIKit

final class RSDropDownCell: UITableViewCell {
    static let reuseIdentifier = "RSDropDownCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectionStyle = .none
    }

    func configure(
        with item: any DropDownItem,
        style: DropDownConfiguration.Style,
        isSelected: Bool,
        showCheckmark: Bool
    ) {
        var content = UIListContentConfiguration.cell()
        content.text = item.dropDownTitle
        content.textProperties.font = style.cellFont
        content.textProperties.color = style.rowTextColor
        content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        if let imageName = item.dropDownImage, let image = UIImage(named: imageName) {
            let imageScale: CGFloat = 0.75
            let imageSize = style.rowHeight * imageScale
            content.image = image
            content.imageProperties.cornerRadius = style.imageCellIsRounded ? imageSize / 2 : 0
            content.imageProperties.maximumSize = CGSize(width: imageSize, height: imageSize)
            content.imageProperties.reservedLayoutSize = CGSize(width: imageSize, height: imageSize)
        }

        contentConfiguration = content
        backgroundColor = isSelected ? style.selectedRowColor : style.rowBackgroundColor
        accessoryType = isSelected && showCheckmark ? .checkmark : .none
        tintColor = .tintColor
    }

    func hidesSeparator(_ hidden: Bool) {
        separatorInset = hidden
            ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }
}
