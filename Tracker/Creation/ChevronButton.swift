//
//  ChevronButton.swift
//  Tracker
//
//  Created by Ди Di on 15/06/25.
//

import UIKit


final class ChevronButton: UIControl {
    private let titleLabel = UILabel()
    private let arrowImageView: UIImageView = {
        let image = UIImage(systemName: "chevron.right")?
            .withTintColor(.ypGray, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var currentTitle: String? { titleLabel.text }
    
    func setTitle(_ text: String) {
        titleLabel.attributedText = nil
        titleLabel.text = text
    }
    
    func setAttributedTitle(_ attribute: NSAttributedString) {
        titleLabel.attributedText = attribute
    }
    
    func setTitleColor(_ color: UIColor) {
        titleLabel.textColor = color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .ypDoubleLightGray
        layer.cornerRadius = 16
        clipsToBounds = true
        
        titleLabel.font = .sfProDisplayRegular17
        titleLabel.textColor = .ypBlack
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowImageView.leadingAnchor, constant: -8),
            
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel, .touchUpOutside])
    }
    
    @objc private func touchDown() {
        alpha = 0.6
    }
    
    @objc private func touchUp() {
        alpha = 1.0
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if bounds.contains(touches.first?.location(in: self) ?? .zero) {
            sendActions(for: .touchUpInside)
        }
    }
}
