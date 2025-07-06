//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Ди Di on 29/05/25.
//

import UIKit


final class TrackerCreationViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.CardCreation.trackerCreationTitle
        label.font = .sfProDisplayMedium16
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.CardCreation.habitButtonTitle, for: .normal)
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .sfProDisplayMedium16
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.CardCreation.irregularEventButtonTitle, for: .normal)
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .sfProDisplayMedium16
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onHabitButtonTap: (() -> Void)?
    var onIrregularEventTap: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            habitButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 281),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func habitButtonTapped() {
        onHabitButtonTap?()
    }
    
    @objc private func irregularEventButtonTapped() {
        onIrregularEventTap?()
    }
}
