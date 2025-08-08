//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Ди Di on 30/06/25.
//

import UIKit


final class NewCategoryViewController: UIViewController {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("enter_category_name_ph", comment: "")
        textField.backgroundColor = .ypDoubleLightGray
        textField.layer.cornerRadius = 16
        textField.font = .sfProDisplayRegular17
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(16)
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("done_button", comment: ""), for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.titleLabel?.font = .sfProDisplayMedium16
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    private let viewModel: TrackerCategoryViewModel
    var onSave: ((String) -> Void)?
    init(viewModel: TrackerCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        title = NSLocalizedString("new_category_title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = false
        setupLayout()
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    private func setupLayout() {
        view.addSubview(textField)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func saveTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        viewModel.addCategory(text)
        onSave?(text)
        dismiss(animated: true)
    }
    
    @objc private func textFieldChanged() {
        let isEmpty = textField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true
        saveButton.isEnabled = !isEmpty
        saveButton.backgroundColor = isEmpty ? .ypGray : .ypBlack
    }
}
