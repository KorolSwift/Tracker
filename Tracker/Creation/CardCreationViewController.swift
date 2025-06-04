//
//  CardCreationViewController.swift
//  Tracker
//
//  Created by Ди Di on 28/05/25.
//

import UIKit


final class CardCreationViewController: UIViewController {
    enum Mode {
        case habit
        case irregularEvent
    }
    private let mode: Mode
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont(name: "SFProDisplay-Medium", size: 16)
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .ypDoubleLightGray
        textView.layer.cornerRadius = 16
        textView.layer.masksToBounds = true
        let verticalInset = (75 - 17) / 2
        textView.textContainerInset = UIEdgeInsets(top: CGFloat(verticalInset), left: 16, bottom: CGFloat(verticalInset), right: 41)
        textView.font = UIFont(name: "SFProDisplay-Regular", size: 17)
        textView.text = "Введите название трекера"
        textView.textColor = .ypGray
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "delete_icon")
        button.setImage(image, for: .normal)
        button.tintColor = .ypGray
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapClear), for: .touchUpInside)
        return button
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont(name: "SFProDisplay-Regular", size: 17)
        label.textColor = .ypRed
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let buttonsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .ypDoubleLightGray
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Категория", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: 17)
        button.setTitleColor(.ypBlack, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let arrowImage = UIImage(systemName: "chevron.right")?
            .withTintColor(.ypGray, renderingMode: .alwaysOriginal)
        button.setImage(arrowImage, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = .zero
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let scheduleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Расписание", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: 17)
        button.setTitleColor(.ypBlack, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.textAlignment = .left
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let arrowImage = UIImage(systemName: "chevron.right")?
            .withTintColor(.ypGray, renderingMode: .alwaysOriginal)
        button.setImage(arrowImage, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = .zero
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonsSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dayAbbreviations: [String: String] = [
        "Понедельник": "Пн",
        "Вторник":     "Вт",
        "Среда":       "Ср",
        "Четверг":     "Чт",
        "Пятница":     "Пт",
        "Суббота":     "Сб",
        "Воскресенье": "Вс"
    ]
    
    private var currentSelectedDays: [String] = []
    private let emojies = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    private lazy var bottomButtonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 16)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 16)
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onSave: ((Card, String) -> Void)?
    private var selectedEmoji: String = ""
    private var selectedColor: UIColor = .ypBlue
    private var isScheduleSelected: Bool = false
    private var buttonsContainerTopToDescConstraint: NSLayoutConstraint!
    private var buttonsContainerTopToErrorConstraint: NSLayoutConstraint!

    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    var initialDescription: String?
    var initialSelectedDays: [String]?
    
    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        switch mode {
        case .habit:
            titleLabel.text = "Новая привычка"
        case .irregularEvent:
            titleLabel.text = "Новое нерегулярное событие"
        }
        
        if mode == .irregularEvent {
            scheduleButton.isHidden = true
            buttonsSeparator.isHidden = true
        }
        navigationController?.navigationBar.prefersLargeTitles = true
        descriptionTextView.delegate = self
        
        saveButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancellButtonTapped), for: .touchUpInside)
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionTextView)
        view.addSubview(clearButton)
        view.addSubview(errorLabel)
        buttonsContainer.addSubview(categoryButton)
        buttonsContainer.addSubview(buttonsSeparator)
        buttonsContainer.addSubview(scheduleButton)
        view.addSubview(buttonsContainer)
        view.addSubview(emojiCollectionView)
        view.addSubview(bottomButtonStack)
        
        setupConstraints()
        
        if let description = initialDescription {
            descriptionTextView.text = description
            descriptionTextView.textColor = .ypBlack
        }
        if let selectedDays = initialSelectedDays, !selectedDays.isEmpty {
            currentSelectedDays = selectedDays
            updateScheduleButtonTitle(from: selectedDays)
            isScheduleSelected = true
        }
    }
    
    private func setupConstraints() {
        buttonsContainerTopToDescConstraint = buttonsContainer.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 24)
        buttonsContainerTopToErrorConstraint = buttonsContainer.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24)
        buttonsContainerTopToDescConstraint.isActive = true
        buttonsContainerTopToErrorConstraint.isActive = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint (equalTo: view.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 75),
            
            clearButton.widthAnchor.constraint(equalToConstant: 17),
            clearButton.heightAnchor.constraint(equalToConstant: 17),
            clearButton.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor, constant: -12),
            clearButton.centerYAnchor.constraint(equalTo: descriptionTextView.centerYAnchor),
            
            errorLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 4),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonsContainer.heightAnchor.constraint(equalToConstant: (mode == .habit ? 150 : 75)),
            
            emojiCollectionView.topAnchor.constraint(equalTo: buttonsContainer.bottomAnchor, constant: 50),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            categoryButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 74.5),
            
            bottomButtonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomButtonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomButtonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        if mode == .habit {
            NSLayoutConstraint.activate([
                buttonsSeparator.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
                buttonsSeparator.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor,constant: 16),
                buttonsSeparator.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor,constant: -16),
                buttonsSeparator.heightAnchor.constraint(equalToConstant: 1),
                
                scheduleButton.topAnchor.constraint(equalTo: buttonsSeparator.bottomAnchor),
                scheduleButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
                scheduleButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
                scheduleButton.heightAnchor.constraint(equalToConstant: 74.5)
            ])
        }}
    
    @objc private func didTapClear() {
        descriptionTextView.text = ""
        clearButton.isHidden = true
        descriptionTextView.text = "Введите название трекера"
        descriptionTextView.textColor = .ypGray
        updateSaveButtonState()
    }
    
    private func showErrorLabel(_ show: Bool) {
        if show {
            buttonsContainerTopToDescConstraint.isActive = false
            buttonsContainerTopToErrorConstraint.isActive = true
        } else {
            buttonsContainerTopToErrorConstraint.isActive = false
            buttonsContainerTopToDescConstraint.isActive = true
        }
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        errorLabel.isHidden = !show
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func createButtonTapped() {
        let categoryTitle = categoryButton.currentTitle ?? "Новая секция"
        let chosenColorName = "ypBlue"
        let card = Card(
            id: UUID(),
            emoji: selectedEmoji,
            description: descriptionTextView.text ?? "",
            colorName: chosenColorName,
            selectedDays: currentSelectedDays,
            originalSectionTitle: categoryTitle
        )
        onSave?(card, categoryTitle)
        dismiss(animated: true)
    }
    
    @objc private func scheduleButtonTapped() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.initialSelectedDays = currentSelectedDays
        
        scheduleViewController.onSave = { [weak self] selectedDays in
            guard let self = self else { return }
            guard !selectedDays.isEmpty else { return }
            self.updateScheduleButtonTitle(from: selectedDays)
            self.isScheduleSelected = true
            self.currentSelectedDays = selectedDays
            self.updateSaveButtonState()
        }
        let nav = UINavigationController(rootViewController: scheduleViewController)
        present(nav, animated: true)
    }
    
    private func updateScheduleButtonTitle(from days: [String]) {
        let fullText: String
        if days.count == 7 {
            fullText = "Расписание\nКаждый день"
        } else {
            let shortList = days.compactMap { self.dayAbbreviations[$0] }
            let daysText = shortList.joined(separator: ", ")
            fullText = "Расписание\n" + daysText
        }
        
        let attributedText = NSMutableAttributedString(string: fullText)
        let firstLineRange = (fullText as NSString).range(of: "Расписание")
        let secondLineRange = (fullText as NSString).range(of: fullText.replacingOccurrences(of: "Расписание\n", with: ""))
        
        attributedText.addAttribute(.foregroundColor, value: UIColor.ypBlack, range: firstLineRange)
        attributedText.addAttribute(.foregroundColor, value: UIColor.ypGray, range: secondLineRange)
        
        scheduleButton.titleLabel?.numberOfLines = 2
        scheduleButton.setAttributedTitle(attributedText, for: .normal)
    }
    
    @objc private func textFieldChanged() {
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        let trimmed = descriptionTextView.text.trimmingCharacters(in: .whitespaces)
        let isTextValid = (!trimmed.isEmpty && descriptionTextView.textColor != .ypGray)
        
        let shouldEnable: Bool
        switch mode {
        case .habit:
            shouldEnable = isTextValid && isScheduleSelected
        case .irregularEvent:
            shouldEnable = isTextValid
        }
        saveButton.backgroundColor = shouldEnable ? .ypBlack : .ypGray
        saveButton.isEnabled = shouldEnable
    }
    
    @objc private func cancellButtonTapped() {
        dismiss(animated: true)
    }
}

extension CardCreationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        clearButton.isHidden = textView.text.isEmpty
        let maxCharacters = 38
        let currentText = textView.text ?? ""
        
        if currentText.count > maxCharacters {
            textView.text = String(currentText.prefix(maxCharacters))
            showErrorLabel(true)
        } else {
            showErrorLabel(false)
        }
        updateSaveButtonState()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Введите название трекера" {
            textView.text = ""
            textView.textColor = .ypBlack
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            textView.text = "Введите название трекера"
            textView.textColor = .ypGray
            errorLabel.isHidden = true
        }
        clearButton.isHidden = true
        updateSaveButtonState()
    }
}

extension CardCreationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        cell.configure(with: emojies[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedEmoji = emojies[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interItemSpacing: CGFloat = 6 * (6 - 1) 
        let availableWidth = collectionView.bounds.width - interItemSpacing
        let cellWidth = availableWidth / 6.0
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
