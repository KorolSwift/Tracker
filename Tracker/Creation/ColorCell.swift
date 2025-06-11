//
//  ColorCell.swift
//  Tracker
//
//  Created by Ди Di on 06/06/25.
//

import UIKit


final class ColorCell: UICollectionViewCell {
    private let colorView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 8
        v.layer.masksToBounds = true
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override var isSelected: Bool {
        didSet {
            contentView.layer.borderWidth = isSelected ? 3 : 0
            contentView.layer.borderColor = isSelected
                ? colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
                : nil
        }
    }

    func configure(with color: UIColor) {
        colorView.backgroundColor = color
    }
}
