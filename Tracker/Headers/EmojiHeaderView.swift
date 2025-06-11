//
//  EmojiHeaderView.swift
//  Tracker
//
//  Created by Ди Di on 06/06/25.
//

import UIKit


final class EmojiHeaderView: UICollectionReusableView {
    static let reuseId = "EmojiHeaderView"
    
    let title: UILabel = {
        let label = UILabel()
        label.font = .sfProDisplayBold19
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .ypWhite
        addSubview(title)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            title.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}
