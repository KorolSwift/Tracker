//
//  StatisticsCardView.swift
//  Tracker
//
//  Created by Ди Di on 01/08/25.
//

import UIKit


final class StatisticsCardView: UIView {
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    private let gradientBorderLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = 16
        layer.borderColor = nil
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        valueLabel.font = .sfProDisplayBold34
        titleLabel.font = .sfProDisplayMedium12
        titleLabel.textColor = .ypBlack
        
        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 7
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 90),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    func configure(value: Int, title: String, color: UIColor) {
        valueLabel.text = "\(value)"
        titleLabel.text = title
        layer.borderColor = color.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradientBorder()
    }
    
    private func setupGradientBorder() {
        gradientBorderLayer.removeFromSuperlayer()
        shapeLayer.removeFromSuperlayer()
        gradientBorderLayer.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemBlue.cgColor
        ]
        gradientBorderLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientBorderLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientBorderLayer.frame = bounds
        gradientBorderLayer.cornerRadius = 16
        
        shapeLayer.lineWidth = 2
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientBorderLayer.mask = shapeLayer
        
        layer.addSublayer(gradientBorderLayer)
        layer.insertSublayer(gradientBorderLayer, at: 0)
    }
}
