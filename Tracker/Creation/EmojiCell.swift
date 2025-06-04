//
//  EmojiCell.swift
//  Tracker
//
//  Created by Ди Di on 02/06/25.
//

import UIKit


final class EmojiCell: UICollectionViewCell {
    private let emojiLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        emojiLabel.font = .systemFont(ofSize: 32)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
}
