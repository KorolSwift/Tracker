//
//  ChooseDayCell.swift
//  Tracker
//
//  Created by Ди Di on 01/06/25.
//

import UIKit


final class ChooseDayCell: UITableViewCell {
    static let reuseIdentifier = "ChooseDayCell"
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .sfProDisplayRegular17
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daySwitch: UISwitch = {
        let day = UISwitch()
        day.onTintColor = UIColor.ypBlue
        day.translatesAutoresizingMaskIntoConstraints = false
        return day
    }()
    
    var toggleSwitch: UISwitch {
        return daySwitch
    }
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(daySwitch)
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(dayName: String, isOn: Bool) {
        dayLabel.text = dayName
        daySwitch.isOn = isOn
    }
    
    func hideSeparator(_ hide: Bool) {
        separator.isHidden = hide
    }
}
