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
    private let existingCardId: UUID?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.CardCreation.titleLabel
        label.font = .sfProDisplayMedium16
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
        textView.font = .sfProDisplayRegular17
        textView.text = Constants.CardCreation.descriptionTextView
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
        label.text = Constants.CardCreation.errorLabel
        label.font = .sfProDisplayRegular17
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
    
    private lazy var categoryButton: ChevronButton = {
        let button = ChevronButton()
        button.setTitle(Constants.CardCreation.categoryButtonTitle)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var currentSelectedCategory: TrackerCategory?
    private let initialSelectedCategory: TrackerCategory?
    private let categoryStore = TrackerCategoryStore(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    private lazy var categoryViewModel = TrackerCategoryViewModel(store: categoryStore)
    
    private lazy var scheduleButton: ChevronButton = {
        let button = ChevronButton()
        button.setTitle(Constants.CardCreation.scheduleButtonTitle)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
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
        button.setTitle(Constants.CardCreation.saveButtonTitle, for: .normal)
        button.titleLabel?.font = .sfProDisplayMedium16
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
        button.setTitle(Constants.CardCreation.cancelButtonTitle, for: .normal)
        button.titleLabel?.font = .sfProDisplayMedium16
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cardStore: CardStore
    var onSave: ((Card, String) -> Void)?
    private var selectedEmoji: String = ""
    private var selectedColor: UIColor = .ypBlue
    private var isScheduleSelected: Bool = false
    private var buttonsContainerTopToDescConstraint: NSLayoutConstraint!
    private var buttonsContainerTopToErrorConstraint: NSLayoutConstraint!
    
    private let emojiHeaderView = EmojiHeaderView()
    private let colorHeaderView = ColorHeaderView()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 42)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.register(EmojiHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "EmojiHeaderView")
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    static let emojies = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private var selectedEmojiIndex: IndexPath?
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 42)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.register(ColorHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ColorHeaderView")
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    static let colors: [UIColor] = [
        .selection1, .selection2, .selection3, .selection4, .selection5, .selection6,
        .selection7, .selection8, .selection9, .selection10, .selection11, .selection12,
        .selection13, .selection14, .selection15, .selection16, .selection17, .selection18
    ]
    
    private var selectedColorIndex: IndexPath?
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    var initialDescription: String?
    var initialSelectedDays: [String]?
    var initialEmojiIndex: IndexPath?
    var initialColorIndex: IndexPath?
    
    init(
        mode: Mode,
        existingCardId: UUID? = nil,
        initialSelectedEmojiIndex: IndexPath? = nil,
        initialSelectedColorIndex: IndexPath? = nil,
        initialDescription: String? = nil,
        initialSelectedDays: [String]? = nil,
        initialSelectedCategory: TrackerCategory? = nil,
        cardStore: CardStore
    ) {
        self.mode = mode
        self.existingCardId = existingCardId
        self.initialEmojiIndex = initialSelectedEmojiIndex
        self.initialColorIndex = initialSelectedColorIndex
        self.initialDescription = initialDescription
        self.initialSelectedDays = initialSelectedDays
        self.initialSelectedCategory = initialSelectedCategory
        self.currentSelectedCategory = initialSelectedCategory
        self.cardStore = cardStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        switch mode {
        case .habit: titleLabel.text = "Новая привычка"
        case .irregularEvent: titleLabel.text = "Новое нерегулярное событие"
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        descriptionTextView.delegate = self
        
        categoryButton.setTitle(Constants.CardCreation.categoryButtonTitle)
        categoryButton.setTitleColor(.ypBlack)
        
        updateScheduleButtonTitle(from: currentSelectedDays)
        
        if let days = initialSelectedDays, !days.isEmpty {
            currentSelectedDays = days
            updateScheduleButtonTitle(from: days)
            isScheduleSelected = true
        }
        
        saveButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancellButtonTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        view.addSubview(bottomButtonStack)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(clearButton)
        contentView.addSubview(errorLabel)
        contentView.addSubview(buttonsContainer)
        
        if mode == .habit {
            buttonsContainer.addSubview(categoryButton)
            buttonsContainer.addSubview(buttonsSeparator)
            buttonsContainer.addSubview(scheduleButton)
        } else {
            buttonsContainer.addSubview(categoryButton)
        }
        
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorCollectionView)
        
        setupLayout()
        
        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
        
        if let description = initialDescription {
            descriptionTextView.text = description
            descriptionTextView.textColor = .ypBlack
        }
        if let selectedDays = initialSelectedDays, !selectedDays.isEmpty {
            currentSelectedDays = selectedDays
            updateScheduleButtonTitle(from: selectedDays)
            isScheduleSelected = true
        }
        if let emojiIndex = initialEmojiIndex {
            selectedEmojiIndex = emojiIndex
            selectedEmoji = CardCreationViewController.emojies[emojiIndex.item]
            emojiCollectionView.selectItem(at: emojiIndex, animated: false, scrollPosition: [])
        }
        if let colorIndex = initialColorIndex {
            selectedColorIndex = colorIndex
            selectedColor = CardCreationViewController.colors[colorIndex.item]
            colorCollectionView.selectItem(at: colorIndex, animated: false, scrollPosition: [])
        }
        if let selected = currentSelectedCategory {
            updateCategoryButtonTitle(from: selected)
        }
        if let category = initialSelectedCategory {
            currentSelectedCategory = category
            updateCategoryButtonTitle(from: category)
        }
    }
    
    private func setupLayout() {
        buttonsContainerTopToDescConstraint = buttonsContainer.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 24)
        buttonsContainerTopToErrorConstraint = buttonsContainer.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24)
        buttonsContainerTopToDescConstraint.isActive = true
        buttonsContainerTopToErrorConstraint.isActive = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomButtonStack.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            descriptionTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 75),
            
            clearButton.centerYAnchor.constraint(equalTo: descriptionTextView.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor, constant: -12),
            clearButton.widthAnchor.constraint(equalToConstant: 17),
            clearButton.heightAnchor.constraint(equalToConstant: 17),
            
            errorLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 4),
            errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            buttonsContainer.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            buttonsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonsContainer.heightAnchor.constraint(equalToConstant: mode == .habit ? 150 : 75),
            
            emojiCollectionView.topAnchor.constraint(equalTo: buttonsContainer.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            contentView.bottomAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 32),
            
            bottomButtonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomButtonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomButtonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomButtonStack.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        if mode == .habit {
            NSLayoutConstraint.activate([
                categoryButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
                categoryButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
                categoryButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
                categoryButton.heightAnchor.constraint(equalToConstant: 74.5),
                
                buttonsSeparator.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
                buttonsSeparator.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor, constant: 16),
                buttonsSeparator.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor, constant: -16),
                buttonsSeparator.heightAnchor.constraint(equalToConstant: 1),
                
                scheduleButton.topAnchor.constraint(equalTo: buttonsSeparator.bottomAnchor),
                scheduleButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
                scheduleButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
                scheduleButton.heightAnchor.constraint(equalToConstant: 74.5)
            ])
        } else {
            NSLayoutConstraint.activate([
                categoryButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
                categoryButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
                categoryButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
                categoryButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor)
            ])
        }
        if let category = currentSelectedCategory {
            categoryButton.setTitle(category.name)
        }
    }
    
    @objc private func didTapClear() {
        descriptionTextView.text = ""
        clearButton.isHidden = true
        descriptionTextView.text = Constants.CardCreation.didTapClearTitle
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
        let categoryTitle = currentSelectedCategory?.name ?? ""
        let index = selectedColorIndex?.item ?? 0
        let card = Card(
            id: existingCardId ?? UUID(),
            emoji: selectedEmoji,
            description: descriptionTextView.text ?? "",
            colorIndex: index,
            selectedDays: currentSelectedDays,
            originalSectionTitle: categoryTitle,
            
            isPinned: false,
            category: currentSelectedCategory
        )
        onSave?(card, card.originalSectionTitle)
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
        guard !days.isEmpty else {
            scheduleButton.setTitle(Constants.CardCreation.scheduleButtonTitle)
            scheduleButton.setTitleColor(.ypBlack)
            return
        }
        let full: String = days.count == 7
        ? "Расписание\nКаждыйвот  день"
        : "Расписание\n" + days.map { dayAbbreviations[$0]! }.joined(separator: ", ")
        let attr = NSMutableAttributedString(string: full)
        let headerRange = (full as NSString).range(of: "Расписание")
        let bodyRange = NSRange(location: headerRange.length+1, length: full.count - headerRange.length - 1)
        attr.addAttribute(.foregroundColor, value: UIColor.ypBlack, range: headerRange)
        attr.addAttribute(.foregroundColor, value: UIColor.ypGray,  range: bodyRange)
        scheduleButton.setAttributedTitle(attr)
    }
    
    @objc private func categoryButtonTapped() {
        let categoryViewController = CategoryViewController(viewModel: categoryViewModel)
        categoryViewController.initialSelectedCategory = currentSelectedCategory
        categoryViewController.onSave = { [weak self] selectedCategory in
            guard let self = self else { return }
            guard !selectedCategory.name.isEmpty else { return }
            
            self.currentSelectedCategory = selectedCategory
            self.updateCategoryButtonTitle(from: selectedCategory)
            self.updateSaveButtonState()
        }
        
        let nav = UINavigationController(rootViewController: categoryViewController)
        present(nav, animated: true)
    }
    
    private func updateCategoryButtonTitle(from category: TrackerCategory) {
        let title = "Категория\n" + category.name
        let attribute = NSMutableAttributedString(string: title)
        
        let headerRange = (title as NSString).range(of: "Категория")
        let bodyRange = NSRange(location: headerRange.length + 1, length: title.count - headerRange.length - 1)
        
        attribute.addAttribute(.foregroundColor, value: UIColor.ypBlack, range: headerRange)
        attribute.addAttribute(.foregroundColor, value: UIColor.ypGray, range: bodyRange)
        categoryButton.setAttributedTitle(attribute)
    }
    
    @objc private func textFieldChanged() {
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        let textValid = !descriptionTextView.text.trimmingCharacters(in: .whitespaces).isEmpty && descriptionTextView.textColor != .ypGray
        let canCreate: Bool
        switch mode {
        case .habit:
            canCreate = textValid && isScheduleSelected && selectedEmojiIndex != nil && selectedColorIndex != nil
        case .irregularEvent:
            canCreate = textValid && selectedEmojiIndex != nil && selectedColorIndex != nil
        }
        saveButton.isEnabled = canCreate
        saveButton.backgroundColor = canCreate ? .ypBlack : .ypGray
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
        return collectionView == emojiCollectionView
        ? CardCreationViewController.emojies.count
        : CardCreationViewController.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            if let previous = selectedEmojiIndex, previous != indexPath {
                collectionView.deselectItem(at: previous, animated: false)
            }
            selectedEmojiIndex = indexPath
            selectedEmoji = CardCreationViewController.emojies[indexPath.item]
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        } else {
            if let previous = selectedColorIndex, previous != indexPath {
                collectionView.deselectItem(at: previous, animated: false)
            }
            selectedColorIndex = indexPath
            selectedColor = CardCreationViewController.colors[indexPath.item]
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        updateSaveButtonState()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 6
        let totalSpacing = 16 + 16 + (itemsPerRow - 1) * 5
        let width = (collectionView.bounds.width - totalSpacing) / itemsPerRow
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let rawCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
            guard let cell = rawCell as? EmojiCell else {
                assertionFailure("Не удалось получить EmojiCell")
                return UICollectionViewCell()
            }
            let emoji = CardCreationViewController.emojies[indexPath.item]
            cell.configure(with: emoji)
            return cell
        } else {
            let rawCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
            guard let cell = rawCell as? ColorCell else {
                assertionFailure("Не удалось получить ColorCell")
                return UICollectionViewCell()
            }
            let color = CardCreationViewController.colors[indexPath.item]
            cell.configure(with: color)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        if collectionView == emojiCollectionView {
            let rawHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmojiHeaderView", for: indexPath)
            guard let header = rawHeader as? EmojiHeaderView else {
                assertionFailure("Не удалось получить EmojiHeaderView")
                return UICollectionReusableView()
            }
            header.title.text = "Emoji"
            return header
        } else {
            let rawHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ColorHeaderView", for: indexPath)
            guard let header = rawHeader as? ColorHeaderView else {
                assertionFailure("Не удалось получить ColorHeaderView")
                return UICollectionReusableView()
            }
            header.title.text = "Цвет"
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 42)
    }
}
