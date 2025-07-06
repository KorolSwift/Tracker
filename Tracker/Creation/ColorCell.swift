//
//  ColorCell.swift
//  Tracker
//
//  Created by Ди Di on 06/06/25.
//

import UIKit


final class ColorCell: UICollectionViewCell {
    private let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private var storedColor: UIColor = .clear
    
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
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override var isSelected: Bool {
        didSet {
            updateBorder()
        }
    }
    
    private func updateBorder() {
        contentView.layer.borderWidth = isSelected ? 3 : 0
        contentView.layer.borderColor = isSelected
        ? storedColor.withAlphaComponent(0.3).cgColor
        : UIColor.clear.cgColor
    }
    
    func configure(with color: UIColor) {
        storedColor = color
        colorView.backgroundColor = color
        updateBorder()
    }
}
