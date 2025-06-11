//
//  EmojiCell.swift
//  Tracker
//
//  Created by Ди Di on 02/06/25.
//

import UIKit


final class EmojiCell: UICollectionViewCell {
    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 32)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 32),
            emojiLabel.heightAnchor.constraint(equalToConstant: 38)
        ])
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? .ypLightGray : .clear
        }
    }

    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
}
