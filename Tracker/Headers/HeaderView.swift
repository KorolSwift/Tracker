//
//  HeaderView.swift
//  Tracker
//
//  Created by Ди Di on 28/05/25.
//

import UIKit


final class HeaderView: UICollectionReusableView {
    let title = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
